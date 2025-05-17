extends Node

@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

func _ready():
	set_audio_volumes()

func set_audio_volumes():
	if not ResourceLoader.exists(Global.SETTINGS_PATH): # default values if there is no save file
		AudioServer.set_bus_volume_db(MASTER_BUS_ID, linear_to_db(0.5))
		AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(1))
		AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(1))
		Global.settings.mute_in_background = true
		return
	Global.load_audio_volumes()

func _notification(what):
	if Global.settings.mute_in_background:
		match what:
			NOTIFICATION_APPLICATION_FOCUS_OUT:
				AudioServer.set_bus_mute(0, true) # 0 = master bus
			NOTIFICATION_APPLICATION_FOCUS_IN:
				AudioServer.set_bus_mute(0, false)
	else:
		AudioServer.set_bus_mute(0, false) # just in case
