extends Control

@onready var continue_button = $"Continue Button"
@onready var character_select_scene = preload("res://Scenes/UI/Character Select.tscn")

func _ready():
	if ResourceLoader.exists(Global.SAVE_PATH):
		continue_button.disabled = false
	if continue_button.disabled:
		$"Continue Button/Text".self_modulate = Color("818181") # matching the border colour

func _on_play_button_pressed():
	get_tree().change_scene_to_packed(character_select_scene)

func _on_continue_button_pressed():
	Global.load_room()
	Pool.continue_run()
	get_tree().change_scene_to_packed(load(LevelList.loaded_current_room))
