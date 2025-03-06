extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var acceleration = $Acceleration
@onready var lifetime = $Lifetime
@onready var detect_pomegranate = $"Detect Pomegranate"
@onready var collision_shape_2d = $"Detect Pomegranate/CollisionShape2D"

const EXPLOSION = preload("res://Scenes/Passives/Effects/Explosion.tscn")
const MAX_STACKS: int = 8
const MAX_DAMAGE: float = 5.0
const MAX_SIZE: float = 3.0
const MAX_SPEED: float = 0.0
const MAX_BLAST_RADIUS: float = 2.0
const ELAPSED_TIME_BUFFER: float = 0.25

var stacks: int = 1
var original_size
var accelerating := false

var pome_queue: Array
var random_num: int
static var spawn_order: int
var spawn_id: int
var num_of_stacks: int
var time_elapsed: float

func _ready():
	super._ready()
	deceleration.start()
	lifetime.start()
	spawn_id = spawn_order
	spawn_order += 1
	random_num = [-1, 1].pick_random()
	original_size = scale * SIZE

func _physics_process(delta):
	super._physics_process(delta)
	scale = original_size * SIZE
	time_elapsed += delta
	check_stack_size()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta * deceleration.time_left / deceleration.wait_time
	rotation += TAU * random_num * delta * deceleration.time_left / deceleration.wait_time
	pome_queue = detect_pomegranate.get_overlapping_areas()
	if pome_queue.size() > 0:
		if is_instance_valid(pome_queue[0]):
			if pome_queue[0].get_parent().time_elapsed >= ELAPSED_TIME_BUFFER:
				if not accelerating:
					acceleration.start()
					accelerating = true
				direction = global_position.direction_to(pome_queue[0].get_parent().global_position).normalized()
				position += current_velocity * delta * \
						(acceleration.wait_time - acceleration.time_left) / acceleration.wait_time / 2
				lifetime.stop()
	else:
		if lifetime.is_stopped():
			lifetime.start()

func travelled_distance():
	pass

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.bubble_pop_2)
	explode()
	queue_free.call_deferred()

func _on_pomegranate_hit_area_area_entered(area):
	if area.get_parent().stacks > stacks: # if the pomegranate is smaller than the one it collided with
		area.get_parent().num_of_stacks = stacks
		queue_free()
	elif area.get_parent().stacks == stacks: # if they are the same size
		if area.get_parent().spawn_id < spawn_id: # if the pomegranate is newer than the one it collided with
			area.get_parent().num_of_stacks = stacks
			queue_free()
		else: # if the pomegranate is older
			combine()
	else: # if the pomegranate is bigger
		combine()

# make each stacked pomegranate stronger as they are combined together
func combine():
	stacks = min(stacks + num_of_stacks, MAX_STACKS)
	BASE_DAMAGE = min(BASE_DAMAGE + 0.5 * stacks, MAX_DAMAGE)
	BASE_SIZE = min(BASE_SIZE + 0.1 * stacks, MAX_SIZE)
	BASE_SPEED = max(BASE_SPEED - 0.1 * stacks, MAX_SPEED)
	BASE_BLAST_RADIUS = min(BASE_BLAST_RADIUS + 0.2 * stacks, MAX_BLAST_RADIUS)
	if deceleration.is_stopped():
		deceleration.start(0.25)

func check_stack_size():
	if stacks >= 8:
		explode()

func explode():
	# shoots the next seed a number of times, depending on the amount of pomegranates stacked together
	var num_of_shots: int
	match stacks:
		1, 2, 3:
			num_of_shots = 4
			SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion_3)
		4, 5, 6:
			num_of_shots = 6
			SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion_2)
		7, 8:
			num_of_shots = 8
			SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion)
	var rotated_direction = [0, PI/num_of_shots] # some variance in the rotation of the shots
	var random_rotation = rotated_direction.pick_random()
	for i in num_of_shots:
		weapon_direction = Vector2.RIGHT.rotated(i * TAU/num_of_shots + random_rotation)
		shoot_next_weapon()
	var explosion = EXPLOSION.instantiate()
	explosion.damage = DAMAGE / 10 + 1 / MAX_STACKS * stacks
	explosion.size = SIZE / 5 + 1 / MAX_STACKS * stacks
	explosion.source = self
	explosion.collisions = collisions
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	explosion.modulate = Color("bf214d")
	call_deferred("create_child", explosion)
	queue_free.call_deferred()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func initialize_location(weapon):
	weapon.transferred_range_multiplier = transferred_range_multiplier + 0.5 / MAX_STACKS * stacks
	weapon.transferred_size_multiplier = transferred_size_multiplier + 1 / MAX_STACKS * stacks
	weapon.transferred_damage_multiplier = transferred_damage_multiplier * 0.5 + 2.5 / MAX_STACKS * stacks
	weapon.transferred_blast_radius_multiplier = transferred_blast_radius_multiplier + 0.75 / MAX_STACKS * stacks
	super.initialize_location(weapon)

func _on_lifetime_timeout():
	explode()
