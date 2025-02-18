class_name settings_data extends Resource

@export var master_volume: float
@export var SFX_volume: float
@export var music_volume: float

func get_audio_volumes():
	master_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	SFX_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	music_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))

func set_audio_volumes():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), SFX_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)
