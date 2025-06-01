extends Node

func _ready():
	set_game_settings()

func set_game_settings():
	if not FileAccess.file_exists(Global.SETTINGS_PATH): # default values if there is no save file
		Global.settings.auto_equip = true
		Global.settings.input_icons = 0
		Global.settings.left_deadzone = 0.15
		Global.settings.right_deadzone = 0.15
		return
	Global.load_game_settings()
