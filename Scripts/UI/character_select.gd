extends Control

const character = preload("res://Scripts/UI/character.gd")
@onready var characters = $Characters.get_children()

func _ready():
	for i in range(characters.size()):
		characters[i].gui_input.connect(select_gui_input.bind(characters[i]))

func select_gui_input(event: InputEvent, char_select: character):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			await get_tree().create_timer(0.05).timeout # prevents immediately firing weapon when loading in
			char_select.select_character()
