extends Control

var SAVE_PATH: String
var RUN_SAVE_PATH: String
var save
var delete_button
var num

func _ready():
	%NoButton.grab_focus()
	get_tree().paused = true
	Game.audio_manager.play(Game.audio_manager.popup_2)
	$TextureRect/RichTextLabel.text = "[center]Are you sure you want to delete save file " + str(num) + "?"

func _on_yes_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	delete()

func _on_no_button_pressed():
	close()

func close():
	Game.audio_manager.play(Game.audio_manager.popup_close_2)
	save.grab_focus()
	get_tree().paused = false
	queue_free()

func delete():
	Global.delete_data(SAVE_PATH, RUN_SAVE_PATH)
	save.get_node("Control").visible = false
	save.get_node("Empty Text").visible = true
	delete_button.disabled = true
	delete_button.visible = false
	close()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close()
		if event.keycode == KEY_ENTER:
			Game.audio_manager.play(Game.audio_manager.ui_button)
			delete()
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_B:
			close()
