extends Control

@onready var key = $Key
@onready var icon = $Icon
@onready var icon_mouse = $"Icon Mouse"
@onready var popup = get_owner()

const ControllerIconMapping = preload("res://Scripts/UI/controller_icon_mapping.gd")

@onready var controller_mapping = ControllerIconMapping.new()

var player
var inventory

func _ready():
	icon_mouse.visible = false
	icon.visible = false
	key.visible = false

func _physics_process(delta):
	player = Targets.get_player()
	inventory = player.inventory
	if player == null:
		return
	
	visible = player.popup != null
	
	icon.visible = false
	icon_mouse.visible = false
	key.visible = false
	
	icon.texture = null
	icon_mouse.texture = null
	key.text = ""
	
	if InputMap.has_action("pick_up"):
		if not InputMap.action_get_events("pick_up").is_empty():
			var event = InputMap.action_get_events("pick_up")[0]
			if event is InputEventKey:
				key.text = OS.get_keycode_string(event.physical_keycode)
			elif event is InputEventMouseButton:
				match event.button_index:
					MOUSE_BUTTON_LEFT:
						icon_mouse.texture = controller_mapping.get_icon("MOUSE_BUTTON_LEFT")
					MOUSE_BUTTON_RIGHT:
						icon_mouse.texture = controller_mapping.get_icon("MOUSE_BUTTON_RIGHT")
					MOUSE_BUTTON_MIDDLE:
						icon_mouse.texture = controller_mapping.get_icon("MOUSE_BUTTON_MIDDLE")
					MOUSE_BUTTON_WHEEL_DOWN:
						icon_mouse.texture = controller_mapping.get_icon("MOUSE_BUTTON_WHEEL_DOWN")
					MOUSE_BUTTON_WHEEL_UP:
						icon_mouse.texture = controller_mapping.get_icon("MOUSE_BUTTON_WHEEL_UP")
	
	if InputMap.has_action("pick_up"):
		if not InputMap.action_get_events("pick_up").is_empty():
			var event = InputMap.action_get_events("pick_up")[1]
			if event is InputEventJoypadButton:
				match event.button_index:
					JOY_BUTTON_A:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_A")
					JOY_BUTTON_B:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_B")
					JOY_BUTTON_X:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_X")
					JOY_BUTTON_Y:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_Y")
					JOY_BUTTON_DPAD_UP:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_UP")
					JOY_BUTTON_DPAD_DOWN:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_DOWN")
					JOY_BUTTON_DPAD_LEFT:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_LEFT")
					JOY_BUTTON_DPAD_RIGHT:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_RIGHT")
					JOY_BUTTON_LEFT_SHOULDER:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_LEFT_SHOULDER")
					JOY_BUTTON_RIGHT_SHOULDER:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_RIGHT_SHOULDER")
					JOY_BUTTON_LEFT_STICK:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_LEFT_STICK")
					JOY_BUTTON_RIGHT_STICK:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_RIGHT_STICK")
					JOY_BUTTON_BACK:
						icon.texture = controller_mapping.get_icon("JOY_BUTTON_BACK")
			elif event is InputEventJoypadMotion:
				match event.axis:
					JOY_AXIS_TRIGGER_LEFT:
						icon.texture = controller_mapping.get_icon("JOY_AXIS_TRIGGER_LEFT")
					JOY_AXIS_TRIGGER_RIGHT:
						icon.texture = controller_mapping.get_icon("JOY_AXIS_TRIGGER_RIGHT")
	
	if player._isKeyboard:
		key.visible = key.text != ""
		icon_mouse.visible = icon_mouse.texture != null
	else:
		icon.visible = true
