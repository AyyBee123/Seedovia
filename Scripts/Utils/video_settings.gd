extends Node

@onready var FULLSCREEN = DisplayServer.window_get_mode()
@onready var VSYNC = DisplayServer.window_get_vsync_mode()

func _ready():
	set_video_settings()

func set_video_settings():
	if FULLSCREEN == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(Vector2i(1280, 720))
		var center_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
		var window_size = get_window().get_size_with_decorations()
		var new_window_position = center_screen - window_size / 2
		get_window().set_position(new_window_position)
	
	if Global.settings.target_FPS == 0:
		Engine.max_fps = 300
	else:
		Engine.max_fps = Global.settings.target_FPS
	
	if not ResourceLoader.exists(Global.SETTINGS_PATH): # default values if there is no save file
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Global.settings.screen_shake = true
		Global.settings.target_FPS = Engine.max_fps
		Global.settings.target_FPS_index = 9
		return
	Global.load_video_settings()
