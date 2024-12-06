class_name overall_data extends Resource

@export var last_played: String

func get_save_selection_data():
	last_played = SelectionSaveData.last_played

func set_save_selection_data():
	SelectionSaveData.last_played = last_played
