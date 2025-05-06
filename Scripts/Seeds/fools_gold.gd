extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const GOLD = preload("res://Scenes/Seeds/Effects/Fools Gold Gold.tscn")

const NUMBER_OF_GOLD = 4
const NUMBER_OF_SEEDS = 4
const ROTATION_SPEED = 4

var _clockwise: bool

func _ready():
	randomize()
	super._ready()
	rotation = randf_range(0, TAU)
	_clockwise = randf() < 0.5

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta
	if _clockwise:
		rotation_degrees += ROTATION_SPEED
	else:
		rotation_degrees -= ROTATION_SPEED

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		for i in NUMBER_OF_SEEDS:
			weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
			shoot_next_weapon()
		for i in NUMBER_OF_GOLD:
			spawn_gold()
		SfxDeconflicter.play(Game.audio_manager.rock)
		explode()
		queue_free.call_deferred()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 \
			else PlayerSeeds.seeds[slot_index + 1]
	SfxDeconflicter.play(Game.audio_manager.rock)
	SfxDeconflicter.play(Game.audio_manager.rock_2)
	for i in NUMBER_OF_SEEDS / 2:
		weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		shoot_next_weapon()
	for i in NUMBER_OF_GOLD / 2:
		spawn_gold()
	explode()
	queue_free.call_deferred()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.3
	splash.source = self
	if shader:
		splash.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		splash.get_node("AnimatedSprite2D").material.shader = shader
	splash.modulate = Color("333b3f")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func spawn_gold():
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var gold = GOLD.instantiate()
	gold.shader = shader
	gold.source = source
	gold.previous_weapon = previous_weapon
	gold.target_group = target_group
	gold.collisions = collisions
	gold.desired_direction = weapon_direction
	gold.slot_index = slot_index
	gold.seed_slot_number = seed_slot_number
	gold.ignore_first_collision = ignore_first_collision
	gold.transferred_speed_multiplier *= transferred_speed_multiplier
	gold.transferred_range_multiplier *= transferred_range_multiplier
	gold.transferred_size_multiplier *= transferred_size_multiplier
	gold.transferred_damage_multiplier *= transferred_damage_multiplier
	gold.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
	gold.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
	gold.modulate = modulate
	get_tree().current_scene.add_child.call_deferred(gold)
	gold.global_position = global_position
	weapon_fired.emit(gold)
