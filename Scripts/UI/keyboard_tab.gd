extends MarginContainer

@onready var keybind_container = %KeybindContainer

const SETTING_KEYBIND_LABEL = preload("res://Scenes/UI/Setting Keybind Label.tscn")
const SETTING_KEYBIND_BUTTON = preload("res://Scenes/UI/Setting Keybind Button.tscn")
const ControllerIconMapping = preload("res://Scripts/UI/controller_icon_mapping.gd")

@onready var controller_mapping = ControllerIconMapping.new()

var _is_remapping: bool = false
var input_to_remap
var remapping_button
var _is_controller: bool
var text = "[center]{input}"

var ACTIONS = {
	"shoot": "Shoot",
	"inventory_use": "Use",
	"pick_up": "Interact",
	"inventory_drop": "Drop",
	"dash": "Dash",
	"inventory": "Inventory",
	"stat_sheet": "Character Sheet"
}

func _ready():
	get_owner().save_button_pressed.connect(_save_inputs)
	_create_action_list()

func _process(delta):
	if _is_remapping:
		remapping_button.grab_focus()

func _create_action_list():
	for input in ACTIONS:
		var label = SETTING_KEYBIND_LABEL.instantiate()
		var button = SETTING_KEYBIND_BUTTON.instantiate()
		var controller_button = SETTING_KEYBIND_BUTTON.instantiate()
		
		label.text = ACTIONS[input] + "        " # i hate godot ui
		button.set_pressed(false)
		button.get_node("Icon").texture = null
		
		if InputMap.has_action(input):
			if not InputMap.action_get_events(input).is_empty():
				var event = InputMap.action_get_events(input)[0]
				if event is InputEventKey:
					button.get_node("Text").text = text.format({"input": \
							OS.get_keycode_string(event.physical_keycode)})
				elif event is InputEventMouseButton:
					match event.button_index:
						MOUSE_BUTTON_LEFT:
							button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_LEFT")
						MOUSE_BUTTON_RIGHT:
							button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_RIGHT")
						MOUSE_BUTTON_MIDDLE:
							button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_MIDDLE")
						MOUSE_BUTTON_WHEEL_DOWN:
							button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_WHEEL_DOWN")
						MOUSE_BUTTON_WHEEL_UP:
							button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_WHEEL_UP")
			else:
				button.get_node("Text").text = text.format({"input": "Not Bound"})
		
		if InputMap.has_action(input):
			if not InputMap.action_get_events(input).is_empty():
				var event = InputMap.action_get_events(input)[1]
				if event is InputEventJoypadButton:
					match event.button_index:
						JOY_BUTTON_A:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_A")
						JOY_BUTTON_B:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_B")
						JOY_BUTTON_X:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_X")
						JOY_BUTTON_Y:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_Y")
						JOY_BUTTON_DPAD_UP:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_UP")
						JOY_BUTTON_DPAD_DOWN:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_DOWN")
						JOY_BUTTON_DPAD_LEFT:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_LEFT")
						JOY_BUTTON_DPAD_RIGHT:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_RIGHT")
						JOY_BUTTON_LEFT_SHOULDER:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_LEFT_SHOULDER")
						JOY_BUTTON_RIGHT_SHOULDER:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_RIGHT_SHOULDER")
						JOY_BUTTON_LEFT_STICK:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_LEFT_STICK")
						JOY_BUTTON_RIGHT_STICK:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_RIGHT_STICK")
						JOY_BUTTON_BACK:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_BACK")
				elif event is InputEventJoypadMotion:
					match event.axis:
						JOY_AXIS_TRIGGER_LEFT:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_AXIS_TRIGGER_LEFT")
						JOY_AXIS_TRIGGER_RIGHT:
							controller_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_AXIS_TRIGGER_RIGHT")
			else:
				controller_button.get_node("Text").text = text.format({"input": "Not Bound"})
		
		button.get_node("Text").visible = button.get_node("Icon").texture == null
		controller_button.get_node("Text").visible = controller_button.get_node("Icon").texture == null
		
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
	_button.find_child("Text").visible = true
	_button.find_child("Icon").texture = null
	_button.find_child("Text").text = text.format({"input": "Press Key..."})

func _on_input_controller_button_pressed(_button, _input):
	if _is_remapping:
		return
	_is_remapping = true
	input_to_remap = _input
	remapping_button = _button
	_is_controller = true
	_button.find_child("Text").visible = true
	_button.find_child("Icon").texture = null
	_button.find_child("Text").text = text.format({"input": "Press Button..."})

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
	if _is_controller and event is InputEventJoypadButton and event.pressed:
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
	elif _is_controller and event is InputEventJoypadMotion and (event.axis == JOY_AXIS_TRIGGER_LEFT \
			or event.axis == JOY_AXIS_TRIGGER_RIGHT):
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
	if event is InputEventKey:
		var key_char := str(char(event.unicode)).to_upper()
		if key_char and key_char.strip_edges() != "":
			_button.get_node("Text").text = text.format({"input": key_char})
		else:
			_button.get_node("Text").text = text.format({"input": OS.get_keycode_string(event.physical_keycode)})
	elif event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_LEFT")
			MOUSE_BUTTON_RIGHT:
				_button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_RIGHT")
			MOUSE_BUTTON_MIDDLE:
				_button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_MIDDLE")
			MOUSE_BUTTON_WHEEL_DOWN:
				_button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_WHEEL_DOWN")
			MOUSE_BUTTON_WHEEL_UP:
				_button.get_node("Icon").texture = controller_mapping.get_icon("MOUSE_BUTTON_WHEEL_UP")
			_:
				_update_action_list(_button, event)
	elif event is InputEventJoypadButton:
		match event.button_index:
			JOY_BUTTON_A:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_A")
			JOY_BUTTON_B:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_B")
			JOY_BUTTON_X:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_X")
			JOY_BUTTON_Y:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_Y")
			JOY_BUTTON_DPAD_UP:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_UP")
			JOY_BUTTON_DPAD_DOWN:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_DOWN")
			JOY_BUTTON_DPAD_LEFT:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_LEFT")
			JOY_BUTTON_DPAD_RIGHT:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_DPAD_RIGHT")
			JOY_BUTTON_LEFT_SHOULDER:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_LEFT_SHOULDER")
			JOY_BUTTON_RIGHT_SHOULDER:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_RIGHT_SHOULDER")
			JOY_BUTTON_LEFT_STICK:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_LEFT_STICK")
			JOY_BUTTON_RIGHT_STICK:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_RIGHT_STICK")
			JOY_BUTTON_BACK:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_BUTTON_BACK")
			_:
				_update_action_list(_button, event)
	elif event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_TRIGGER_LEFT:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_AXIS_TRIGGER_LEFT")
			JOY_AXIS_TRIGGER_RIGHT:
				_button.get_node("Icon").texture = controller_mapping.get_icon("JOY_AXIS_TRIGGER_RIGHT")
			#_:
				#_update_action_list(_button, event)
	else:
		_button.get_node("Text").text = text.format({"input": event})
	
	_button.get_node("Text").visible = _button.get_node("Icon").texture == null
