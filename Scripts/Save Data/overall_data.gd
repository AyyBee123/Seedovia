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
@export var ach_07_blueberry: bool
@export var ach_07_progress: float
@export var ach_08_goldbasket: bool
@export var ach_08_progress: float
@export var ach_09_shadeslash: bool
@export var ach_09_progress: float
@export var ach_10_wavyshroom: bool
@export var ach_10_progress: float
@export var ach_11_metronome: bool
@export var ach_11_progress: float
@export var ach_12_pizzadisc: bool
@export var ach_12_progress: float
@export var ach_13_whitechaos: bool
@export var ach_13_progress: float
@export var ach_14_sell: bool
@export var ach_14_progress: float
@export var ach_15_circleofseeds: bool
@export var ach_15_progress: float
@export var ach_16_jelly: bool
@export var ach_16_progress: float

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
	ach_07_blueberry = Game.achievement_handler.ach_07_blueberry.completed
	ach_07_progress = Game.achievement_handler.ach_07_blueberry.get_progress()
	ach_08_goldbasket = Game.achievement_handler.ach_08_goldbasket.completed
	ach_08_progress = Game.achievement_handler.ach_08_goldbasket.get_progress()
	ach_09_shadeslash = Game.achievement_handler.ach_09_shadeslash.completed
	ach_09_progress = Game.achievement_handler.ach_09_shadeslash.get_progress()
	ach_10_wavyshroom = Game.achievement_handler.ach_10_wavyshroom.completed
	ach_10_progress = Game.achievement_handler.ach_10_wavyshroom.get_progress()
	ach_11_metronome = Game.achievement_handler.ach_11_metronome.completed
	ach_11_progress = Game.achievement_handler.ach_11_metronome.get_progress()
	ach_12_pizzadisc = Game.achievement_handler.ach_12_pizzadisc.completed
	ach_12_progress = Game.achievement_handler.ach_12_pizzadisc.get_progress()
	ach_13_whitechaos = Game.achievement_handler.ach_13_whitechaos.completed
	ach_13_progress = Game.achievement_handler.ach_13_whitechaos.get_progress()
	ach_14_sell = Game.achievement_handler.ach_14_sell.completed
	ach_14_progress = Game.achievement_handler.ach_14_sell.get_progress()
	ach_15_circleofseeds = Game.achievement_handler.ach_15_circleofseeds.completed
	ach_15_progress = Game.achievement_handler.ach_15_circleofseeds.get_progress()
	ach_16_jelly = Game.achievement_handler.ach_16_jelly.completed
	ach_16_progress = Game.achievement_handler.ach_16_jelly.get_progress()

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
	Game.achievement_handler.ach_07_blueberry.completed = ach_07_blueberry
	Game.achievement_handler.ach_07_blueberry.set_progress(ach_07_progress)
	Game.achievement_handler.ach_08_goldbasket.completed = ach_08_goldbasket
	Game.achievement_handler.ach_08_goldbasket.set_progress(ach_08_progress)
	Game.achievement_handler.ach_09_shadeslash.completed = ach_09_shadeslash
	Game.achievement_handler.ach_09_shadeslash.set_progress(ach_09_progress)
	Game.achievement_handler.ach_10_wavyshroom.completed = ach_10_wavyshroom
	Game.achievement_handler.ach_10_wavyshroom.set_progress(ach_10_progress)
	Game.achievement_handler.ach_11_metronome.completed = ach_11_metronome
	Game.achievement_handler.ach_11_metronome.set_progress(ach_11_progress)
	Game.achievement_handler.ach_12_pizzadisc.completed = ach_12_pizzadisc
	Game.achievement_handler.ach_12_pizzadisc.set_progress(ach_12_progress)
	Game.achievement_handler.ach_13_whitechaos.completed = ach_13_whitechaos
	Game.achievement_handler.ach_13_whitechaos.set_progress(ach_13_progress)
	Game.achievement_handler.ach_14_sell.completed = ach_14_sell
	Game.achievement_handler.ach_14_sell.set_progress(ach_14_progress)
	Game.achievement_handler.ach_15_circleofseeds.completed = ach_15_circleofseeds
	Game.achievement_handler.ach_15_circleofseeds.set_progress(ach_15_progress)
	Game.achievement_handler.ach_16_jelly.completed = ach_16_jelly
	Game.achievement_handler.ach_16_jelly.set_progress(ach_16_progress)

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
	ach_06_veapea = false
	ach_06_progress = 0
	ach_07_blueberry = false
	ach_07_progress = 0
	ach_08_goldbasket = false
	ach_08_progress = 0
	ach_09_shadeslash = false
	ach_09_progress = 0
	ach_10_wavyshroom = false
	ach_10_progress = 0
	ach_11_metronome = false
	ach_11_progress = 0
	ach_12_pizzadisc = false
	ach_12_progress = 0
	ach_13_whitechaos = false
	ach_13_progress = 0
	ach_14_sell = false
	ach_14_progress = 0
	ach_15_circleofseeds = false
	ach_15_progress = 0
	ach_16_jelly = false
	ach_16_progress = 0

func get_achievement(_ach):
	return _ach
