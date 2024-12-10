class_name overall_data extends Resource

@export var last_played: String
@export var number_of_runs: int
@export var time_played: float

## Achievements and their progress
@export var ach_01_die: bool
@export var ach_01_progress: float

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

func reset_stats():
	time_played = 0
	number_of_runs = 0

func get_achievements():
	ach_01_die = Game.achievement_handler.ach_01_die.completed
	ach_01_progress = Game.achievement_handler.ach_01_die.get_progress()
	

func set_achievements():
	Game.achievement_handler.ach_01_die.completed = ach_01_die
	Game.achievement_handler.ach_01_die.set_progress(ach_01_progress)
	

func reset_achievements():
	ach_01_die = false
	ach_01_progress = 0
	

func get_achievement(_ach):
	return _ach
