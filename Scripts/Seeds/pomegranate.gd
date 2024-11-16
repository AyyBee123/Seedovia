extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var acceleration = $Acceleration
@onready var lifetime = $Lifetime
@onready var detect_pomegranate = $"Detect Pomegranate"
@onready var collision_shape_2d = $"Detect Pomegranate/CollisionShape2D"

const MAX_STACKS: int = 8
const MAX_DAMAGE: float = 5.0
const MAX_SIZE: float = 3.0
const MIN_SPEED: float = 0.0
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
	spawn_id = spawn_order
	spawn_order += 1
	random_num = [-1, 1].pick_random()
	original_size = scale * player._player_stats.get_stat("Weapon_Size")

func _physics_process(delta):
	super._physics_process(delta)
	scale = original_size * size_multiplier
	time_elapsed += delta
	check_stack_size()

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta * deceleration.time_left / deceleration.wait_time
	rotation += 2 * PI * random_num * delta * deceleration.time_left / deceleration.wait_time
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
		body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
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
	damage_multiplier = min(damage_multiplier + 0.5 * num_of_stacks, MAX_DAMAGE)
	size_multiplier = min(size_multiplier + 0.3 * num_of_stacks, MAX_SIZE)
	speed_multiplier = max(speed_multiplier - 0.1, MIN_SPEED)
	blast_radius_multiplier = min(blast_radius_multiplier + 0.2 * num_of_stacks, MAX_BLAST_RADIUS)
	stacks = min(stacks + num_of_stacks, MAX_STACKS)
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
		4, 5, 6:
			num_of_shots = 6
		7, 8:
			num_of_shots = 8
	var rotated_direction = [0, PI/num_of_shots] # some variance in the rotation of the shots
	var random_rotation = rotated_direction.pick_random()
	for i in num_of_shots:
		weapon_direction = Vector2.RIGHT.rotated(2 * i * PI/num_of_shots + random_rotation)
		shoot_next_weapon()
	queue_free.call_deferred()

func get_weapon_properties(weapon, _desired_direction, _ignore_first_collision = false, _enemy = null):
	weapon.initial_weapon = false
	weapon.ignore_first_collision = _ignore_first_collision
	weapon.desired_direction = _desired_direction
	weapon.previous_weapon = self
	weapon.hit_enemy = _enemy
	weapon.slot_index = slot_index + 1
	weapon.transferred_speed_multiplier = transferred_speed_multiplier
	weapon.transferred_range_multiplier = transferred_range_multiplier + 0.5 / MAX_STACKS * stacks
	weapon.transferred_size_multiplier = transferred_size_multiplier + 1 / MAX_STACKS * stacks
	weapon.transferred_damage_multiplier = transferred_damage_multiplier * 0.5 + 2.5 / MAX_STACKS * stacks
	weapon.transferred_blast_radius_multiplier = transferred_blast_radius_multiplier + 0.75 / MAX_STACKS * stacks
	weapon.transferred_fire_rate_multiplier = transferred_fire_rate_multiplier
	if seed_slot_number < 2:
		weapon.seed_slot_number = PlayerSeeds.seed_indices[slot_index + 1]
	else:
		weapon.seed_slot_number = 3
	initialize_location.call_deferred(weapon)

func _on_lifetime_timeout():
	explode()
