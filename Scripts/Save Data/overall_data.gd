class_name overall_data extends Resource

@export var last_played: String
@export var number_of_runs: int
@export var time_played: float

func get_save_selection_data():
	last_played = SelectionSaveData.last_played
	number_of_runs = SelectionSaveData.number_of_runs

func set_save_selection_data():
	SelectionSaveData.last_played = last_played
	SelectionSaveData.number_of_runs = number_of_runs

func get_time_played():
	time_played = SelectionSaveData.time_played

func set_time_played():
	SelectionSaveData.time_played = time_played
