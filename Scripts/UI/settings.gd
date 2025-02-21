extends Control

var source

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Global.save_settings()
		queue_free()

func _ready():
	%MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	%SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	%MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	%MasterEdit.text = str(int(snapped( \
			db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))), 0.01) * 100))
	%SFXEdit.text = str(int(snapped( \
			db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))), 0.01) * 100))
	%MusicEdit.text = str(int(snapped( \
			db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))), 0.01) * 100))

func _on_master_slider_value_changed(value):
	change_volume(Game.audio_settings.MASTER_BUS_ID, value)
	# snapped basically rounds the value to the nearest hundredth in this case (the 0.01 value)
	# this avoids the text value changing to 75, for example when typing 76 (float is something like 75.9999...
	# changed to 75 instead of 76 when cast to an int
	%MasterEdit.text = str(int(snapped( \
			db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))), 0.01) * 100))

func _on_sfx_slider_value_changed(value):
	change_volume(Game.audio_settings.SFX_BUS_ID, value)
	%SFXEdit.text = str(int(snapped( \
			db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))), 0.01) * 100))

func _on_music_slider_value_changed(value):
	change_volume(Game.audio_settings.MUSIC_BUS_ID, value)
	%MusicEdit.text = str(int(snapped( \
			db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))), 0.01) * 100))

func _on_master_edit_text_submitted(new_text):
	if new_text == "":
		%MasterEdit.text = str(int(%MasterSlider.value * 100))
		%MasterEdit.release_focus()
		return
	var value = int(new_text)
	value = clampi(0, value, 100)
	change_volume(Game.audio_settings.MASTER_BUS_ID, value / 100.0)
	%MasterSlider.value = value / 100.0
	%MasterEdit.release_focus()

func _on_sfx_edit_text_submitted(new_text):
	if new_text == "":
		%SFXEdit.text = str(int(%SFXSlider.value * 100))
		%SFXEdit.release_focus()
		return
	var value = int(new_text)
	value = clampi(0, value, 100)
	change_volume(Game.audio_settings.SFX_BUS_ID, value / 100.0)
	%SFXSlider.value = value / 100.0
	%SFXEdit.release_focus()

func _on_music_edit_text_submitted(new_text):
	if new_text == "":
		%MusicEdit.text = str(int(%MusicSlider.value * 100))
		%MusicEdit.release_focus()
		return
	var value = int(new_text)
	value = clampi(0, value, 100)
	change_volume(Game.audio_settings.MUSIC_BUS_ID, value / 100.0)
	%MusicSlider.value = value / 100.0
	%MusicEdit.release_focus()

func change_volume(audio, value):
	AudioServer.set_bus_volume_db(audio, linear_to_db(value))
	AudioServer.set_bus_mute(audio, value == 0)

func _on_save_button_pressed():
	Global.save_settings()
	if source: # if the settings menu was instantiated from the pause menu
		source.priority_popups.pop_front()
	queue_free()

func _on_cancel_button_pressed():
	if source: # if the settings menu was instantiated from the pause menu
		source.priority_popups.pop_front()
	queue_free()
