extends Node

# %APPDATA%\Roaming\Godot\app_userdata\Roguelike
var SAVE_PATH := "user://save_data.res"
var RUN_SAVE_PATH := "user://current_run.res"
var data := player_data.new()
var super_data := overall_data.new()
var rewards: Array
static var next_reward: item_pool = null
var cursor = load("res://Sprites/UI/Cursor.png")
var RNG
var loaded_room_file: String

func save_run_data():
	data.get_character()
	data.get_coins()
	data.get_inventory()
	data.get_passives()
	data.get_item_passives()
	data.get_stats()
	data.get_pools()
	ResourceSaver.save(data, RUN_SAVE_PATH)
	ResourceSaver.save(data, "user://current_run.tres") # for testing purposes, will remove later

func load_run_data():
	if not ResourceLoader.exists(RUN_SAVE_PATH):
		return
	data = ResourceLoader.load(RUN_SAVE_PATH)
	data.set_character()
	data.set_coins()
	data.set_stats()
	data.set_passives()
	data.set_item_passives()
	data.set_inventory()
	data.set_pools()

func save_run_room():
	data.get_current_room()
	ResourceSaver.save(data, RUN_SAVE_PATH)
	ResourceSaver.save(data, "user://current_run.tres") # for testing purposes, will remove later

func load_run_room():
	if not ResourceLoader.exists(RUN_SAVE_PATH):
		return
	data = ResourceLoader.load(RUN_SAVE_PATH)
	data.set_current_room()

func delete_run_data():
	if not ResourceLoader.exists(RUN_SAVE_PATH):
		return
	DirAccess.remove_absolute(RUN_SAVE_PATH)

func load_run_data_exists() -> bool:
	return ResourceLoader.exists(RUN_SAVE_PATH)

func save_coins():
	data.get_coins()
	ResourceSaver.save(data, RUN_SAVE_PATH)
	ResourceSaver.save(data, "user://current_run.tres") # for testing purposes, will remove later

func load_data(_path = null):
	if _path == null:
		_path = SAVE_PATH
	if not ResourceLoader.exists(_path):
		return
	super_data = ResourceLoader.load(_path)
	super_data.set_save_selection_data()

func save_save_selection():
	super_data.get_save_selection_data()
	ResourceSaver.save(super_data, SAVE_PATH)
	ResourceSaver.save(super_data, "user://save_data.tres") # for testing purposes, will remove later

func save_data():
	ResourceSaver.save(super_data, SAVE_PATH)
	ResourceSaver.save(super_data, "user://save_data.tres") # for testing purposes, will remove later

func load_data_exists(_data) -> bool:
	return ResourceLoader.exists(_data)

func delete_data(_path = null):
	if _path == null:
		_path = SAVE_PATH
	if not ResourceLoader.exists(_path):
		return
	DirAccess.remove_absolute(_path)
