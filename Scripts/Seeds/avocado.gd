extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const AVOCADO_SEED = preload("res://Scenes/Seeds/Effects/Avocado Seed.tscn")
const AVOCADO_LEFT = preload("res://Scenes/Seeds/Effects/Avocado Left.tscn")
const AVOCADO_RIGHT = preload("res://Scenes/Seeds/Effects/Avocado Right.tscn")

var range_reached: bool

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.45
	splash.source = self
	splash.modulate = Color("a8c445")
	SfxDeconflicter.play(Game.audio_manager.crunch)
	SfxDeconflicter.play(Game.audio_manager.hit_2)
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(player._player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.crunch)
	queue_free.call_deferred()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= player._player_stats.get_stat("Weapon_Range") * range_multiplier:
		if not range_reached:
			range_reached_done()
			range_reached = true

func range_reached_done():
	# spawn the seed
	var avocado_seed = AVOCADO_SEED.instantiate()
	transfer_properties(avocado_seed)
	avocado_seed.desired_direction = direction
	avocado_seed.speed_multiplier = speed_multiplier
	avocado_seed.range_multiplier = range_multiplier * 2
	avocado_seed.damage_multiplier = damage_multiplier * 2
	avocado_seed.fire_rate_multiplier = fire_rate_multiplier * 2
	get_tree().current_scene.add_child(avocado_seed)
	avocado_seed.global_position = global_position
	# spawn the left side
	var avocado_left = AVOCADO_LEFT.instantiate()
	transfer_properties(avocado_left)
	avocado_left.desired_direction = direction.rotated(-PI/2)
	avocado_left.speed_multiplier = speed_multiplier
	avocado_left.range_multiplier = range_multiplier
	avocado_left.damage_multiplier = damage_multiplier * 0.5
	avocado_left.fire_rate_multiplier = fire_rate_multiplier
	avocado_left.parent_direction = direction
	avocado_left.angle_sign = -1
	get_tree().current_scene.add_child(avocado_left)
	avocado_left.global_position = global_position + 3 * direction.rotated(-PI/2).normalized()
	# spawn the right side
	var avocado_right = AVOCADO_RIGHT.instantiate()
	transfer_properties(avocado_right)
	avocado_right.desired_direction = direction.rotated(PI/2)
	avocado_right.speed_multiplier = speed_multiplier
	avocado_right.range_multiplier = range_multiplier
	avocado_right.damage_multiplier = damage_multiplier * 0.5
	avocado_right.fire_rate_multiplier = fire_rate_multiplier
	avocado_right.parent_direction = direction
	avocado_right.angle_sign = 1
	get_tree().current_scene.add_child(avocado_right)
	avocado_right.global_position = global_position + 3 * direction.rotated(PI/2).normalized()
	
	explode()
	queue_free.call_deferred()

func transfer_properties(seed):
	seed.scale = scale
	seed.seed_slots = seed_slots
	seed.slot_index = slot_index
	seed.seed_slot_number = seed_slot_number
	seed.transferred_speed_multiplier *= transferred_speed_multiplier
	seed.transferred_range_multiplier *= transferred_range_multiplier
	seed.transferred_size_multiplier *= transferred_size_multiplier
	seed.transferred_damage_multiplier *= transferred_damage_multiplier
	seed.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
	seed.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
	seed.add_child(get_node("Passives").duplicate())
	weapon_fired.emit(seed)
