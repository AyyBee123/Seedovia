extends Node

func _ready():
	set_keybind_settings()

func set_keybind_settings():
	if not FileAccess.file_exists(Global.SETTINGS_PATH): # default values if there is no save file
		return
	Global.load_keybind_settings()
	
	for input in Global.settings.keybinds:
		InputMap.action_erase_events(input)
		for i in Global.settings.keybinds[input]:
			InputMap.action_add_event(input, i)
