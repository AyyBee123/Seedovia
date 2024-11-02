extends Node

# %APPDATA%\Roaming\Godot\app_userdata\Roguelike
var SAVE_PATH := "user://current_run.res"
var data := player_data.new()
var rewards: Array
static var next_reward: item_pool = null
var cursor = load("res://Sprites/UI/Cursor.png")
var RNG

func save_data():
	data.get_sprite()
	data.get_inventory()
	data.get_passives()
	data.get_item_passives()
	data.get_stats()
	ResourceSaver.save(data, SAVE_PATH)

func load_data():
	if not ResourceLoader.exists(SAVE_PATH):
		return
	data = ResourceLoader.load(SAVE_PATH)
	data.set_sprite()
	data.set_stats()
	data.set_passives()
	data.set_item_passives()
	data.set_inventory()

func delete_data():
	if not ResourceLoader.exists(SAVE_PATH):
		return
	DirAccess.remove_absolute(SAVE_PATH)
	
