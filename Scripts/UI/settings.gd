extends Control

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Global.save_settings()
		queue_free()

func _ready():
	%MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	%SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	%MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))

func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Game.audio_settings.MASTER_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Game.audio_settings.MASTER_BUS_ID, value == 0)

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Game.audio_settings.SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Game.audio_settings.SFX_BUS_ID, value == 0)

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Game.audio_settings.MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Game.audio_settings.MUSIC_BUS_ID, value == 0)
