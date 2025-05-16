extends "res://Scripts/UI/menu.gd"

func _ready():
	Game.music_manager.play(Game.music_manager.MENU_THEME)
	seed_list = get_all_file_paths("res://Resources/Items/Seeds/")
