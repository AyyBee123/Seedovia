extends Node

func _ready():
	set_game_settings()

func set_game_settings():
	if not ResourceLoader.exists(Global.SETTINGS_PATH): # default values if there is no save file
		Global.settings.auto_equip = true
		Global.settings.input_icons = 0
		return
	Global.load_game_settings()
