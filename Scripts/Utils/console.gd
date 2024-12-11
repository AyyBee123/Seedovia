extends CanvasLayer

var level
var expression = Expression.new()
var history: Array[String] = []
var hitory_index: int = -1

var ITEM = preload("res://Scenes/Items/item.tscn")
var PICKUP_ITEM = preload("res://Scenes/Items/Pickup Item.tscn")
var SHOP_ITEM = preload("res://Scenes/Items/Shop Item.tscn")

func _ready():
	level = get_parent()
	get_tree().paused = true
	%Input.text_submitted.connect(self._on_text_submitted)
	await get_tree().process_frame # prevent ` from being typed in the console immediately
	%Input.grab_focus()

func _on_text_submitted(command):
	var error = expression.parse(command)
	if error != OK:
		%Console.text += "- " + %Input.text + "\n"
		%Console.text += expression.get_error_text() + "\n"
		%Input.text = ""
		return
	var result = expression.execute([], self)
	if not expression.has_execute_failed():
		%Console.text += "- " + %Input.text + "\n"
		%Console.text += str(result) + "\n"
	%Input.text = ""

func _input(event):
	if event is InputEventKey:
		if (event.keycode == KEY_ESCAPE or event.keycode == 96) and event.pressed:
			get_tree().paused = false

func spawn_item(_entity: String, pos: Vector2 = Vector2.ZERO):
	var item_file_paths := []
	item_file_paths.append_array(get_all_file_paths(Pool.consumable_pool.path))
	item_file_paths.append_array(get_all_file_paths(Pool.equipment_pool.path))
	item_file_paths.append_array(get_all_file_paths(Pool.pickup_pool.path))
	item_file_paths.append_array(get_all_file_paths(Pool.seed_pool.path))
	
	for item in item_file_paths:
		var loaded_item = ResourceLoader.load(item)
		if _entity == loaded_item.item_name:
			if loaded_item.category == "PICKUP":
				var new_item = PICKUP_ITEM.instantiate()
				new_item.set_item(loaded_item)
				level.add_child(new_item)
				new_item.global_position = pos
			else:
				var new_item = ITEM.instantiate()
				new_item.set_item(loaded_item)
				level.add_child(new_item)
				new_item.global_position = pos
			break

func spawn_enemy(_enemy: String, pos: Vector2 = Vector2.ZERO):
	var enemy_file_paths := []
	enemy_file_paths.append_array(get_all_file_paths("res://Scenes/Enemies/"))
	enemy_file_paths.append_array(get_all_file_paths("res://Scenes/Bosses/"))
	
	for enemy in enemy_file_paths:
		if enemy.right(4) == ".tmp":
			continue
		var res = load(enemy)
		if not res is PackedScene:
			continue
		var scene = res.instantiate()
		if _enemy == scene.name:
			level.add_child(scene)
			scene.global_position = pos

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
