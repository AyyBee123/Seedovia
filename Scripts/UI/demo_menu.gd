extends "res://Scripts/UI/menu.gd"

const character_select_scene = preload("res://Scenes/UI/Character Select Demo.tscn")

var cercis = preload("res://Resources/Characters/cercis.tres")
var berry = preload("res://Resources/Characters/berry.tres")

func _ready():
	cercis.unlocked = true
	berry.unlocked = true
	Game.music_manager.play(Game.music_manager.MENU_THEME)
	seed_list = get_all_file_paths("res://Resources/Demo/Seeds/")

func _on_play_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().change_scene_to_packed(character_select_scene)
