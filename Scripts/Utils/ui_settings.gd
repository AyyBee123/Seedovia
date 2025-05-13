extends Node

func _ready():
	set_ui_settings()

func set_ui_settings():
	if not ResourceLoader.exists(Global.SETTINGS_PATH): # default values if there is no save file
		Global.settings.show_timer = true
		Global.settings.show_damage_numbers = true
		Global.settings.show_damage_numbers_2 = true
		Global.settings.show_hints = true
		return
	Global.load_ui_settings()
