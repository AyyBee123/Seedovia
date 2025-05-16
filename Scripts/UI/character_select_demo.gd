extends "res://Scripts/UI/character_select.gd"

var DEMO_MENU = load("res://Scenes/UI/Demo Menu.tscn")

func _on_back_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().change_scene_to_packed(DEMO_MENU)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_packed(DEMO_MENU)
