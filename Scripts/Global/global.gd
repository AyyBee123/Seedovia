extends Node

# %APPDATA%\Roaming\Godot\app_userdata\Roguelike
var SAVE_PATH := "user://save_run_data.res"
var RUN_SAVE_PATH := "user://current_run.res"
var data := player_data.new()
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
