extends "res://Scripts/Seeds/seed_template.gd"

var random_seed

func _ready():
	super._ready()
	shoot_seed()

func shoot_seed():
	var seed = Pool.seed_list.pick_random()
	if ResourceLoader.load(seed).item_name == "Metronome": # skip metronome (obviously)
		shoot_seed()
		return
	var seed_instance = ResourceLoader.load(seed).scene.instantiate()
	set_weapon_properties(seed_instance, desired_direction, ignore_first_collision, hit_enemy)
	destroy()

func set_weapon_properties(weapon, _desired_direction, _ignore_first_collision = false, _enemy = null):
	weapon.initial_weapon = false
	weapon.ignore_first_collision = _ignore_first_collision
	weapon.desired_direction = _desired_direction
	weapon.source = source
	weapon.previous_weapon = previous_weapon
	weapon.hit_enemy = _enemy
	if set_next_seed_slot_index:
		weapon.slot_index = set_next_seed_slot_index
	else:
		weapon.slot_index = slot_index
	weapon.transferred_speed_multiplier *= transferred_speed_multiplier
	weapon.transferred_range_multiplier *= transferred_range_multiplier
	weapon.transferred_size_multiplier *= transferred_size_multiplier
	weapon.transferred_damage_multiplier *= transferred_damage_multiplier
	weapon.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
	weapon.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
	weapon.modulate = modulate
	if set_next_seed_slot_number:
		weapon.seed_slot_number = set_next_seed_slot_number
	else:
		weapon.seed_slot_number = seed_slot_number
	initialize_location.call_deferred(weapon)

func initialize_location(weapon):
	if not get_tree():
		return
	weapon.remove_child(weapon.get_node("Passives"))
	weapon.add_child(get_node("Passives").duplicate())
	get_tree().current_scene.add_child(weapon)
	weapon.global_position = global_position

func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			file_paths += get_all_file_paths(file_path)
		else:
			file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths
