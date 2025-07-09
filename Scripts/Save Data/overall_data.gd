class_name overall_data extends Resource

@export var last_played: String
@export var number_of_runs: int
@export var time_played: float

## Achievements and their progress
@export var ach_01_die: bool
@export var ach_01_progress: float
@export var ach_02_coins: bool
@export var ach_02_progress: float
@export var ach_03_health: bool
@export var ach_03_progress: float
@export var ach_04_swift: bool
@export var ach_04_progress: float
@export var ach_05_pizza: bool
@export var ach_05_progress: float
@export var ach_05_toppings: Array
@export var ach_05_topping_locations: Array
@export var ach_05_failed: bool
@export var ach_05_spawned: Array
@export var ach_06_veapea: bool
@export var ach_06_progress: float

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
	ach_02_coins = Game.achievement_handler.ach_02_coins.completed
	ach_02_progress = Game.achievement_handler.ach_02_coins.get_progress()
	ach_03_health = Game.achievement_handler.ach_03_health.completed
	ach_03_progress = Game.achievement_handler.ach_03_health.get_progress()
	ach_04_swift = Game.achievement_handler.ach_04_swift.completed
	ach_04_progress = Game.achievement_handler.ach_04_swift.get_progress()
	ach_05_pizza = Game.achievement_handler.ach_05_pizza.completed
	ach_05_progress = Game.achievement_handler.ach_05_pizza.get_progress()
	ach_05_toppings = Game.achievement_handler.ach_05_pizza.toppings
	ach_05_topping_locations = Game.achievement_handler.ach_05_pizza.topping_locations
	ach_05_failed = Game.achievement_handler.ach_05_pizza.failed
	ach_05_spawned = Game.achievement_handler.ach_05_pizza.spawned
	ach_06_veapea = Game.achievement_handler.ach_06_veapea.completed
	ach_06_progress = Game.achievement_handler.ach_06_veapea.get_progress()

func set_achievements():
	Game.achievement_handler.ach_01_die.completed = ach_01_die
	Game.achievement_handler.ach_01_die.set_progress(ach_01_progress)
	Game.achievement_handler.ach_02_coins.completed = ach_02_coins
	Game.achievement_handler.ach_02_coins.set_progress(ach_02_progress)
	Game.achievement_handler.ach_03_health.completed = ach_03_health
	Game.achievement_handler.ach_03_health.set_progress(ach_03_progress)
	Game.achievement_handler.ach_04_swift.completed = ach_04_swift
	Game.achievement_handler.ach_04_swift.set_progress(ach_04_progress)
	Game.achievement_handler.ach_05_pizza.completed = ach_05_pizza
	Game.achievement_handler.ach_05_pizza.set_progress(ach_05_progress)
	Game.achievement_handler.ach_05_pizza.toppings = ach_05_toppings
	Game.achievement_handler.ach_05_pizza.topping_locations = ach_05_topping_locations
	Game.achievement_handler.ach_05_pizza.failed = ach_05_failed
	Game.achievement_handler.ach_05_pizza.spawned = ach_05_spawned
	Game.achievement_handler.ach_06_veapea.completed = ach_06_veapea
	Game.achievement_handler.ach_06_veapea.set_progress(ach_06_progress)

func reset_achievements():
	ach_01_die = false
	ach_01_progress = 0
	ach_02_coins = false
	ach_02_progress = 0
	ach_03_health = false
	ach_03_progress = 0
	ach_04_swift = false
	ach_04_progress = 0
	ach_05_pizza = false
	ach_05_progress = 0

func get_achievement(_ach):
	return _ach
