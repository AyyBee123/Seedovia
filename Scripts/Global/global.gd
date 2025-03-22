extends Node

# %APPDATA%\Roaming\Godot\app_userdata\Roguelike
var SAVE_PATH := "user://save_data.res"
var RUN_SAVE_PATH := "user://current_run.res"
var SETTINGS_PATH := "user://settings.res"
var data := player_data.new()
var super_data := overall_data.new()
var settings := settings_data.new()
var rewards: Array
static var next_reward: item_pool = null
var cursor = load("res://Sprites/UI/Cursor.png")
var RNG: RandomNumberGenerator
var loaded_room_file: String
var coins_saving: bool

func save_run_data():
	data.get_character()
	data.get_coins()
	data.get_inventory()
	data.get_passives()
	data.get_item_passives()
	data.get_stats()
	data.get_pools()
	data.get_run_time()
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
	data.set_run_time()

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
	coins_saving = true
	data.get_coins()
	ResourceSaver.save(data, RUN_SAVE_PATH)
	ResourceSaver.save(data, "user://current_run.tres") # for testing purposes, will remove later
	coins_saving = false
	SignalBus.coins_saved.emit()

func load_data(_path = null):
	if _path == null:
		_path = SAVE_PATH
	if not ResourceLoader.exists(_path):
		return
	super_data = ResourceLoader.load(_path)
	super_data.set_save_selection_data()
	super_data.set_time_played()

func save_save_selection():
	super_data.get_save_selection_data()
	super_data.get_time_played()
	ResourceSaver.save(super_data, SAVE_PATH)
	ResourceSaver.save(super_data, "user://save_data.tres") # for testing purposes, will remove later

func save_data():
	super_data.get_achievements()
	super_data.get_time_played()
	ResourceSaver.save(super_data, SAVE_PATH)
	ResourceSaver.save(super_data, "user://save_data.tres") # for testing purposes, will remove later

func load_data_exists(_data) -> bool:
	return ResourceLoader.exists(_data)

func delete_data(_path = null, _run_path = null):
	if _path == null:
		_path = SAVE_PATH
	if _run_path == null:
		_run_path = RUN_SAVE_PATH
	if ResourceLoader.exists(_path):
		DirAccess.remove_absolute(_path)
	if ResourceLoader.exists(_run_path):
		DirAccess.remove_absolute(_run_path)
	super_data.reset_achievements()
	super_data.reset_stats()

func save_time_played():
	super_data.get_time_played()
	ResourceSaver.save(super_data, SAVE_PATH)
	ResourceSaver.save(super_data, "user://save_data.tres") # for testing purposes, will remove later

func save_achievements():
	super_data.get_achievements()
	ResourceSaver.save(super_data, SAVE_PATH)
	ResourceSaver.save(super_data, "user://save_data.tres") # for testing purposes, will remove later

func load_achievements(_path = null):
	if _path == null:
		_path = SAVE_PATH
	if not ResourceLoader.exists(_path):
		return
	super_data = ResourceLoader.load(_path)
	super_data.set_achievements()

func save_settings():
	settings.get_audio_volumes()
	ResourceSaver.save(settings, SETTINGS_PATH)
	ResourceSaver.save(settings, "user://settings.tres") # for testing purposes, will remove later

func load_settings():
	if not ResourceLoader.exists(SETTINGS_PATH):
		return
	settings = ResourceLoader.load(SETTINGS_PATH)
	settings

func load_audio_volumes():
	if not ResourceLoader.exists(SETTINGS_PATH):
		return
	settings = ResourceLoader.load(SETTINGS_PATH)
	settings.set_audio_volumes()
