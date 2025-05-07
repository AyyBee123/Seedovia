extends Control

@onready var continue_button = $"Continue Button"

const SETTINGS = preload("res://Scenes/UI/Settings.tscn")
const MENU = preload("res://Scenes/UI/Menu.tscn")
const character_select_scene = preload("res://Scenes/UI/Character Select.tscn")
const loading_screen_scene = preload("res://Scenes/UI/Loading Screen.tscn")

var loading_screen_scene_instance
var settings
var thread

func _ready():
	Game.music_manager.play(Game.music_manager.MENU_THEME)
	thread = Thread.new()
	if ResourceLoader.exists(Global.RUN_SAVE_PATH):
		continue_button.disabled = false
		$"Continue Button/Text".modulate = Color("e7cca0")
	else:
		continue_button.disabled = true
		$"Continue Button/Text".modulate = Color("d2bdaa")
	Global.load_achievements()

func _on_play_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().change_scene_to_packed(character_select_scene)

func _on_continue_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	loading_screen_scene_instance = loading_screen_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(loading_screen_scene_instance)
	thread.start(continue_run)

func continue_run():
	Global.load_run_data()
	Global.load_run_room()
	LevelList.load_char()
	Pool.continue_run()
	change_scene.call_deferred()

func change_scene():
	thread.wait_to_finish()
	get_tree().change_scene_to_file(LevelList.loaded_current_room)

func _on_settings_button_pressed():
	if get_tree().current_scene.find_child("Settings"): # if a settings scene already exists
		return
	settings = SETTINGS.instantiate()
	settings.default_focus = %"Settings Button"
	get_tree().current_scene.add_child(settings)

func _on_back_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().change_scene_to_packed(MENU)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(settings):
			return
		Game.audio_manager.play(Game.audio_manager.ui_button)
		get_tree().change_scene_to_packed(MENU)
