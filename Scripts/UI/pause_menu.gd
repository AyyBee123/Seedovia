extends Control

const SETTINGS = preload("res://Scenes/UI/Settings.tscn")

var starting_character: character_class
var starting_stats: player_stats
var settings

func _ready():
	get_tree().paused = true
	Game.audio_manager.play(Game.audio_manager.popup_2)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(settings):
			return
		un_pause()

func _on_resume_button_pressed():
	un_pause()

func un_pause():
	get_tree().paused = false
	Game.audio_manager.play(Game.audio_manager.popup_close_2)
	queue_free()

func _on_quick_restart_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	Global.delete_run_data()
	LevelList.elapsed_time = 0
	PlayerCharacter._is_starting = true
	Global.RNG = RandomNumberGenerator.new()
	Global.rewards.clear()
	Global.next_reward = null
	LevelList.floor_number = 0
	LevelList.room_number = 0
	LevelList.floor.rooms.clear()
	LevelList.current_reward_given = true
	LevelList.loaded_room_is_cleared = true
	LevelList.doors.clear()
	LevelList.doors_spawned = false
	LevelList.pickup_items_on_ground.clear()
	LevelList.items_on_ground.clear()
	LevelList.shop_items_on_ground.clear()
	LevelList.coins_on_ground.clear()
	LevelList.shop_items_spawned = false
	get_tree().paused = false
	starting_character = PlayerCharacter.starting_character
	PlayerCharacter.coins = starting_character.starting_coins
	PlayerInventory.inventory.clear()
	PlayerInventory.talismans.clear()
	PlayerInventory.seeds.clear()
	PlayerPassives.passives.clear()
	PlayerPassives.item_passives.clear()
	PlayerPassives.starting_passives.clear()
	PlayerPassives.passive_list.clear()
	PlayerCharacter.set_inventory()
	PlayerCharacter.add_passives()
	SignalBus.entered_new_floor.emit()
	Pool.start()
	Global.save_run_data()
	Global.save_run_room()
	get_tree().change_scene_to_file("res://Scenes/Levels/Special/Starting Room 1.tscn")

func _on_settings_button_pressed():
	if get_tree().current_scene.find_child("Settings"): # if a settings scene already exists
		return
	settings = SETTINGS.instantiate()
	settings.default_focus = %"Settings Button"
	get_tree().current_scene.add_child(settings)

func _on_quit_to_menu_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().paused = false
	if OS.has_feature("demo"):
		get_tree().change_scene_to_file("res://Scenes/UI/Demo Menu.tscn")
		return
	get_tree().change_scene_to_file("res://Scenes/UI/Main Menu.tscn")
