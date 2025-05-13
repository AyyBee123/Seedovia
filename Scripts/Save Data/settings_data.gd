class_name settings_data extends Resource

# game
@export var auto_equip: bool

# video
@export var fullscreen: int
@export var vsync: int

# ui
@export var show_timer: bool
@export var show_damage_numbers: bool
@export var show_damage_numbers_2: bool

# audio
@export var master_volume: float
@export var SFX_volume: float
@export var music_volume: float
@export var mute_in_background: bool

# controls
@export var keybinds: Dictionary

func get_game_settings():
	pass

func get_video_settings():
	fullscreen = DisplayServer.window_get_mode()
	vsync = DisplayServer.window_get_vsync_mode()

func get_ui_settings():
	pass

func get_audio_volumes():
	master_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	SFX_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	music_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))

func set_game_settings():
	pass

func set_video_settings():
	DisplayServer.window_set_mode(fullscreen)
	DisplayServer.window_set_vsync_mode(vsync)

func set_ui_settings():
	pass

func set_audio_volumes():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), SFX_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)

func set_inputs():
	pass
