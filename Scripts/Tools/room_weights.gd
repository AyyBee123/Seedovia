@tool
extends EditorScript

func _run():
	var floors_root = "res://Scenes/Levels/"
	var dir = DirAccess.open(floors_root)
	if dir == null:
		push_error("Cannot open floors root: " + floors_root)
		return

	var output = {}

	dir.list_dir_begin()
	while true:
		var floor_folder = dir.get_next()
		if floor_folder == "":
			break
		if dir.current_is_dir() and not floor_folder.begins_with("."):
			var full_path = floors_root + floor_folder + "/"
			var scene_paths = []
			_get_scene_paths_recursively(full_path, scene_paths)

			for scene_path in scene_paths:
				var scene = load(scene_path)
				if scene == null:
					push_error("Could not load scene: " + scene_path)
					continue

				var instance = scene.instantiate()
				if instance == null:
					push_error("Could not instantiate scene: " + scene_path)
					continue

				var weight = instance.weight
				output[scene_path] = {
					"floor": floor_folder,
					"type": instance.name,
					"weight": weight
				}

				print("✓ ", floor_folder, " - ", scene_path, " → weight: ", weight)

	dir.list_dir_end()

	# Save to JSON
	var file = FileAccess.open("res://room_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(output, "\t"))
	file.close()

	print("\n🎉 Room data exported to room_data.json")


func _get_scene_paths_recursively(folder_path: String, paths: Array):
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Cannot open folder: " + folder_path)
		return

	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		var file_path = folder_path + file_name
		if dir.current_is_dir():
			if file_name.begins_with("."):
				continue
			_get_scene_paths_recursively(file_path + "/", paths)
		elif file_name.ends_with(".tscn"):
			paths.append(file_path)
	dir.list_dir_end()
