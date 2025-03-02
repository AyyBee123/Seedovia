extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
var GRAPE = load("res://Scenes/Seeds/Grape.tscn")

const CHANCE_TO_SHOOT = 0.4

var spread: float
var _spawn_more_grapes: bool = true

func _ready():
	super._ready()
	randomize()
	BASE_RANGE *= randf_range(0.9, 1.1)
	BASE_SIZE *= randf_range(0.8, 1.0)
	BASE_SPEED *= randf_range(0.95, 1.05)
	spread = randf_range(-PI/6,PI/6) # random 30 degree spread
	desired_direction = desired_direction.rotated(spread)
	
	# spawn grapes
	if _spawn_more_grapes:
		await get_tree().physics_frame
		var number_of_grapes = randi_range(5, 7)
		for i in number_of_grapes:
			var grape = GRAPE.instantiate()
			grape.shader = shader
			grape._spawn_more_grapes = false
			grape.source = source
			grape.target_group = target_group
			grape.collisions = collisions
			grape.desired_direction = desired_direction
			grape.slot_index = slot_index
			grape.seed_slot_number = seed_slot_number
			grape.ignore_first_collision = ignore_first_collision
			grape.transferred_speed_multiplier *= transferred_speed_multiplier
			grape.transferred_range_multiplier *= transferred_range_multiplier
			grape.transferred_size_multiplier *= transferred_size_multiplier
			grape.transferred_damage_multiplier *= transferred_damage_multiplier
			grape.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
			grape.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
			get_tree().current_scene.add_child.call_deferred(grape)
			grape.global_position = global_position
			weapon_fired.emit(grape)

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	shoot_next_weapon()
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.bubble_pop_2)
	explode()
	queue_free.call_deferred()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta

func shoot_next_weapon():
	if randf() > CHANCE_TO_SHOOT: # if the roll fails, do not shoot the next weapon
		return
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	super.shoot_next_weapon()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		shoot_next_weapon()
		SfxDeconflicter.play(Game.audio_manager.bubble_pop_2)
		explode()
		queue_free.call_deferred()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.2 * SIZE
	splash.source = self
	if shader:
		splash.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		splash.get_node("AnimatedSprite2D").material.shader = shader
	splash.modulate = Color("312877")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
