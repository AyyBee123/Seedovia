extends Control

@onready var continue_button = $"Continue Button"

func _ready():
	if ResourceLoader.exists(Global.SAVE_PATH):
		continue_button.disabled = false
	if continue_button.disabled:
		$"Continue Button/Text".self_modulate = Color("818181") # matching the border colour

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/Character Select.tscn")

func _on_continue_button_pressed():
	Global.load_room()
	get_tree().change_scene_to_file(LevelList.loaded_current_room)
	
