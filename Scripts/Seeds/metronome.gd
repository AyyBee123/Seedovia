extends "res://Scripts/Seeds/seed_template.gd"

var seed_list: Array = []
var seed_resources
var random_seed

func _ready():
	super._ready()
	seed_resources = get_all_file_paths("res://Resources/Items/Seeds/")
	for seed in seed_resources:
		if ResourceLoader.load(seed).item_name == "Metronome": # skip metronome (obviously)
			continue
		seed_list.append(ResourceLoader.load(seed).scene)
	random_seed = seed_list.pick_random().instantiate()
	set_weapon_properties(random_seed, desired_direction, ignore_first_collision, hit_enemy)
	queue_free.call_deferred()

func _physics_process(delta):
	pass

func set_weapon_properties(weapon, _desired_direction, _ignore_first_collision = false, _enemy = null):
	weapon.initial_weapon = false
	weapon.ignore_first_collision = _ignore_first_collision
	weapon.desired_direction = _desired_direction
	weapon.previous_weapon = self
	weapon.hit_enemy = _enemy
	weapon.slot_index = slot_index
	weapon.transferred_speed_multiplier = transferred_speed_multiplier
	weapon.transferred_range_multiplier = transferred_range_multiplier
	weapon.transferred_size_multiplier = transferred_size_multiplier
	weapon.transferred_damage_multiplier = transferred_damage_multiplier
	weapon.transferred_blast_radius_multiplier = transferred_blast_radius_multiplier
	weapon.transferred_fire_rate_multiplier = transferred_fire_rate_multiplier
	if seed_slot_number < 2:
		weapon.seed_slot_number = PlayerSeeds.seed_indices[slot_index]
	else:
		weapon.seed_slot_number = 3
	initialize_location.call_deferred(weapon)

func initialize_location(weapon):
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
