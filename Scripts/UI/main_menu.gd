extends Control

@onready var continue_button = $"Continue Button"
@onready var character_select_scene = preload("res://Scenes/UI/Character Select.tscn")
@onready var loading_screen_scene = preload("res://Scenes/UI/Loading Screen.tscn")
var loading_screen_scene_instance

func _ready():
	if ResourceLoader.exists(Global.RUN_SAVE_PATH):
		continue_button.disabled = false
	if continue_button.disabled:
		$"Continue Button/Text".self_modulate = Color("818181") # matching the border colour
	Global.load_achievements()

func _on_play_button_pressed():
	get_tree().change_scene_to_packed(character_select_scene)

func _on_continue_button_pressed():
	loading_screen_scene_instance = loading_screen_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(loading_screen_scene_instance)
	await get_tree().create_timer(0.5).timeout # delay to let the loading screen load in and display on-screen
	Global.load_run_room
	Global.load_run_data()
	Global.load_run_room()
	LevelList.load_char()
	Pool.continue_run()
	get_tree().change_scene_to_file(LevelList.loaded_current_room)
