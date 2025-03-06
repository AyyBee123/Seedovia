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
	queue_free.call_deferred()

func initialize_location(weapon):
	weapon.remove_child(weapon.get_node("Passives"))
	weapon.add_child(get_node("Passives").duplicate())
	weapon.previous_weapon = previous_weapon
	weapon.seed_slot_number = seed_slot_number
	weapon.slot_index = slot_index
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
