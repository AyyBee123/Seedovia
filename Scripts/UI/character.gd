extends TextureRect

var mouse_hovered = false
var event: InputEvent
@export var starting_character: character_class

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _physics_process(delta):
	if mouse_hovered == true:
		modulate = Color.BLACK
	else:
		modulate = Color.WHITE

func _on_mouse_entered():
	mouse_hovered = true

func _on_mouse_exited():
	mouse_hovered = false

func select_character():
	print("hi")
