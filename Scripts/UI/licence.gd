extends Control

var default_focus

func _ready():
	%Label.text = Engine.get_license_text()

func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_B:
			close()
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close()

func close():
	queue_free()

func _exit_tree():
	if default_focus:
		default_focus.grab_focus()

func _on_close_button_pressed():
	close()
