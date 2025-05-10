extends Node

var mappings = {
	# mouse inputs
	"MOUSE_BUTTON_LEFT": preload("res://Sprites/Keybinds/Left Mouse Button.png"),
	"MOUSE_BUTTON_RIGHT": preload("res://Sprites/Keybinds/Right Mouse Button.png"),
	"MOUSE_BUTTON_MIDDLE": preload("res://Sprites/Keybinds/Middle Mouse Button.png"),
	"MOUSE_BUTTON_WHEEL_DOWN": preload("res://Sprites/Keybinds/Mouse Scroll Down.png"),
	"MOUSE_BUTTON_WHEEL_UP": preload("res://Sprites/Keybinds/Mouse Scroll Up.png"),
	
	#controller inputs
	"JOY_BUTTON_A": preload("res://Sprites/Keybinds/Bottom Button.png"),
	"JOY_BUTTON_B": preload("res://Sprites/Keybinds/Right Button.png"),
	"JOY_BUTTON_X": preload("res://Sprites/Keybinds/Left Button.png"),
	"JOY_BUTTON_Y": preload("res://Sprites/Keybinds/Top Button.png"),
	"JOY_BUTTON_DPAD_UP": preload("res://Sprites/Keybinds/D-Pad Up.png"),
	"JOY_BUTTON_DPAD_DOWN": preload("res://Sprites/Keybinds/D-Pad Down.png"),
	"JOY_BUTTON_DPAD_LEFT": preload("res://Sprites/Keybinds/D-Pad Left.png"),
	"JOY_BUTTON_DPAD_RIGHT": preload("res://Sprites/Keybinds/D-Pad Right.png"),
	"JOY_AXIS_TRIGGER_RIGHT": preload("res://Sprites/Keybinds/Right Trigger.png"),
	"JOY_AXIS_TRIGGER_LEFT": preload("res://Sprites/Keybinds/Left Trigger.png"),
	"JOY_BUTTON_LEFT_SHOULDER": preload("res://Sprites/Keybinds/Left Bumper.png"),
	"JOY_BUTTON_RIGHT_SHOULDER": preload("res://Sprites/Keybinds/Right Bumper.png"),
	"JOY_BUTTON_LEFT_STICK": preload("res://Sprites/Keybinds/Left Stick Pressed.png"),
	"JOY_BUTTON_RIGHT_STICK": preload("res://Sprites/Keybinds/Right Stick Pressed.png"),
	"JOY_BUTTON_BACK": preload("res://Sprites/Keybinds/Select.png")
}

func get_icon(input):
	return mappings[input]
