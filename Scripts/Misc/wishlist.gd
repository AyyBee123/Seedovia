extends Control

@onready var circle_transition = %"Circle Transition"

func _ready():
	get_tree().paused = false
	circle_transition.visible = true
	circle_transition.get_node("AnimationPlayer").play("Open")
	Game.music_manager.play(Game.music_manager.MENU_THEME)

func _on_wishlist_button_pressed():
	OS.shell_open("steam://store/3636730")

func _on_quit_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/Menu.tscn")
