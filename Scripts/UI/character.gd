extends TextureButton

var mouse_hovered = false
var event: InputEvent
@export var starting_character: character_class
@export var character_scene: String
@export_multiline var unlock_method: String

var _player_stats: player_stats = preload("res://Resources/Characters/Stats/base_stats.tres")

var menu

func _ready():
	menu = get_parent().get_parent()
	if not starting_character.unlocked:
		self_modulate = Color("b9b9b9")
		$"MarginContainer/Character".modulate = Color.BLACK
		mouse_default_cursor_shape = 0

func _physics_process(delta):
	starting_character.unlocked

func _on_pressed():
	menu.starting_character = starting_character
	menu.character_scene = character_scene
	menu._press(self)
