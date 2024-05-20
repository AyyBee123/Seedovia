extends Node

# %APPDATA%\Roaming\Godot\app_userdata\Roguelike
var SAVE_PATH := "user://player_inventory.res"
var data := player_data.new()
var rewards: Array
static var next_reward: item_pool = null

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
