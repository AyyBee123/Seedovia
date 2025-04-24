extends MarginContainer

@onready var keybind_container = %KeybindContainer

const SETTING_KEYBIND_LABEL = preload("res://Scenes/UI/Setting Keybind Label.tscn")
const SETTING_KEYBIND_BUTTON = preload("res://Scenes/UI/Setting Keybind Button.tscn")

var _is_remapping: bool = false
var input_to_remap
var remapping_button
var _is_controller: bool

var ACTIONS = {
	"shoot": "Shoot",
	"use": "Use",
	"pick_up": "Interact",
	"dash": "Dash",
	"inventory": "Inventory",
	"up": "Move Up",
	"down": "Move Down",
	"left": "Move Left",
	"right": "Move Right"
}

func _ready():
	get_owner().save_button_pressed.connect(_save_inputs)
	_create_action_list()

func _create_action_list():
	for input in ACTIONS:
		var label = SETTING_KEYBIND_LABEL.instantiate()
		var button = SETTING_KEYBIND_BUTTON.instantiate()
		var controller_button = SETTING_KEYBIND_BUTTON.instantiate()
		
		label.text = ACTIONS[input] + "        " # i hate godot ui
		button.set_pressed(false)
		
		if InputMap.has_action(input):
			if not InputMap.action_get_events(input).is_empty():
				button.get_node("Text").text = "[center]" + InputMap.action_get_events(input)[0].as_text() \
						.trim_suffix(" (Physical)").trim_suffix(" Button")
			else:
				button.get_node("Text").text = "[center]Not Bound"
		
		if InputMap.has_action(input):
			if not InputMap.action_get_events(input).is_empty():
				controller_button.get_node("Text").text = "[center]" + InputMap.action_get_events(input)[1] \
						.as_text().trim_suffix(" (Physical)").trim_suffix(" Button")
			else:
				controller_button.get_node("Text").text = "[center]Not Bound"
		
		keybind_container.add_child(label)
		keybind_container.add_child(button)
		keybind_container.add_child(controller_button)
		
		button.pressed.connect(_on_input_button_pressed.bind(button, input))
		controller_button.pressed.connect(_on_input_controller_button_pressed.bind(controller_button, input))

func _on_input_button_pressed(_button, _input):
	if _is_remapping:
		return
	_is_remapping = true
	input_to_remap = _input
	remapping_button = _button
	_is_controller = false
	_button.find_child("Text").text = "[center]Press Key..."

func _on_input_controller_button_pressed(_button, _input):
	if _is_remapping:
		return
	_is_remapping = true
	input_to_remap = _input
	remapping_button = _button
	_is_controller = true
	_button.find_child("Text").text = "[center]Press Button..."

func _input(event):
	if not _is_remapping:
		return
	
	# cancel key binding
	if (event is InputEventKey and event.keycode == KEY_ESCAPE) or \
			(event is InputEventJoypadButton and event.button_index == JOY_BUTTON_START):
		var i = int(_is_controller)
		_update_action_list(remapping_button, InputMap.action_get_events(input_to_remap)[i])
		
		_is_remapping = false
		input_to_remap = null
		remapping_button.set_pressed(false)
		remapping_button = null
		
		accept_event()
		return
	
	# keyboard binding
	if not _is_controller and event is InputEventKey or (event is InputEventMouseButton and event.pressed):
		# prevent double click
		if event is InputEventMouseButton and event.double_click:
			event.double_click = false
		
		# damn dude
		var temp = InputMap.action_get_events(input_to_remap)
		InputMap.action_erase_events(input_to_remap)
		InputMap.action_add_event(input_to_remap, event)
		InputMap.action_add_event(input_to_remap, temp[1])
		_update_action_list(remapping_button, event)
		
		_is_remapping = false
		input_to_remap = null
		remapping_button.set_pressed(false)
		remapping_button = null
		
		accept_event()
	
	# controller binding
	if _is_controller and (event is InputEventJoypadButton and event.pressed) or event is InputEventJoypadMotion:
		# damn dude
		var temp = InputMap.action_get_events(input_to_remap)
		InputMap.action_erase_events(input_to_remap)
		InputMap.action_add_event(input_to_remap, temp[0])
		InputMap.action_add_event(input_to_remap, event)
		_update_action_list(remapping_button, event)
		
		_is_remapping = false
		input_to_remap = null
		remapping_button.set_pressed(false)
		remapping_button = null
		
		accept_event()

func _save_inputs():
	for input in ACTIONS:
		if InputMap.has_action(input):
			Global.settings.keybinds[input] = InputMap.action_get_events(input)
	Global.save_settings()

func _update_action_list(_button, event):
	_button.get_node("Text").text = "[center]" + event.as_text() \
			.trim_suffix(" (Physical)").trim_suffix(" Button")
