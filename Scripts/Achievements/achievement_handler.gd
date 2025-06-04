extends Node

var ach_01_die: Ach01Die
var ach_02_coins: Ach02Coins
var ach_03_health: Ach03Health
var ach_04_swift: Ach04Swift
var ach_05_pizza: Ach05Pizza

func _ready():
	ach_01_die = Ach01Die.new()
	add_child(ach_01_die)
	ach_02_coins = Ach02Coins.new()
	add_child(ach_02_coins)
	ach_03_health = Ach03Health.new()
	add_child(ach_03_health)
	ach_04_swift = Ach04Swift.new()
	add_child(ach_04_swift)
	ach_05_pizza = Ach05Pizza.new()
	add_child(ach_05_pizza)
	
	await get_tree().process_frame # ensures all ach children are ready
	
	if not ach_01_die:
		push_error("Achievement handler or nodes not ready.")
		return
	SignalBus.initialized_achievements.emit()
