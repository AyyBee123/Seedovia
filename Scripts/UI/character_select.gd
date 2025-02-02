extends Control

const character = preload("res://Scripts/UI/character.gd")
@onready var characters = $Characters.get_children()
@onready var loading_screen_scene = preload("res://Scenes/UI/Loading Screen.tscn")
var loading_screen_scene_instance

func _ready():
	for i in range(characters.size()):
		characters[i].gui_input.connect(select_gui_input.bind(characters[i]))

func select_gui_input(event: InputEvent, char_select: character):
	if not char_select.starting_character.unlocked:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			loading_screen_scene_instance = loading_screen_scene.instantiate()
			get_tree().current_scene.add_child.call_deferred(loading_screen_scene_instance)
			await get_tree().create_timer(0.5).timeout # delay to let the loading screen load in and display on-screen
			Global.RNG = RandomNumberGenerator.new()
			char_select.select_character()
