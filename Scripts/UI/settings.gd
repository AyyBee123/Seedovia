extends Control

signal save_button_pressed

var source
var temp_master
var temp_sfx
var temp_music
var default_focus

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_cancel_button_pressed()
	if event.is_action_pressed("ui_accept") and event is InputEventKey:
		get_viewport().set_input_as_handled()
		_on_save_button_pressed()
	if event.is_action_pressed("ui_next"):
		if %TabContainer.current_tab >= %TabContainer.get_children().size() - 1:
			%TabContainer.current_tab = 0
		else:
			%TabContainer.current_tab += 1
	if event.is_action_pressed("ui_previous"):
		if %TabContainer.current_tab <= 0:
			%TabContainer.current_tab = %TabContainer.get_children().size() - 1
		else:
			%TabContainer.current_tab -= 1
	if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_START:
		get_viewport().set_input_as_handled()
		_on_save_button_pressed()

func _ready():
	#set current tab to the first one
	%TabContainer.current_tab = 0
	
	# video settings
	%"Fullscreen Button".button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	%"VSync Button".button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	
	# ui settings
	%"Timer Button".button_pressed = Global.settings.show_timer
	%"Damage Button".button_pressed = Global.settings.show_damage_numbers
	
	# audio settings
	%MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	%SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	%MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	%MasterEdit.text = str(int(snapped( \
			db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))), 0.01) * 100))
	%SFXEdit.text = str(int(snapped( \
			db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))), 0.01) * 100))
	%MusicEdit.text = str(int(snapped( \
			db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))), 0.01) * 100))
	
	temp_master = %MasterSlider.value
	temp_sfx = %SFXSlider.value
	temp_music = %MusicSlider.value

func _on_fullscreen_button_toggled(toggled_on):
	Game.audio_manager.play(Game.audio_manager.ui_button)
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_v_sync_button_toggled(toggled_on):
	Game.audio_manager.play(Game.audio_manager.ui_button)
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_timer_button_toggled(toggled_on):
	Game.audio_manager.play(Game.audio_manager.ui_button)

func _on_damage_button_toggled(toggled_on):
	Game.audio_manager.play(Game.audio_manager.ui_button)

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
	Game.audio_manager.play(Game.audio_manager.ui_button)
	# add changes
	Global.settings.show_timer = %"Timer Button".button_pressed
	Global.settings.show_damage_numbers = %"Damage Button".button_pressed
	
	Global.save_settings()
	if source: # if the settings menu was instantiated from the pause menu
		source.priority_popups.pop_front()
	save_button_pressed.emit()
	close()

func _on_cancel_button_pressed():
	Game.audio_manager.play(Game.audio_manager.popup_close_2)
	#revert settings
	DisplayServer.window_set_mode(Global.settings.fullscreen)
	DisplayServer.window_set_vsync_mode(Global.settings.vsync)
	
	change_volume(Game.audio_settings.MASTER_BUS_ID, temp_master)
	change_volume(Game.audio_settings.SFX_BUS_ID, temp_sfx)
	change_volume(Game.audio_settings.MUSIC_BUS_ID, temp_music)
	
	if source: # if the settings menu was instantiated from the pause menu
		source.priority_popups.pop_front()
	close()

func close():
	queue_free()

func _on_tab_container_tab_changed(tab):
	Game.audio_manager.play(Game.audio_manager.use_2)
	%TabContainer.get_tab_bar().grab_focus.call_deferred()

func _on_auto_equip_button_toggled(toggled_on):
	Game.audio_manager.play(Game.audio_manager.ui_button)

func _exit_tree():
	if default_focus:
		default_focus.grab_focus()
