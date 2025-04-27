extends Node

var ach_01_die: Ach01Die
var ach_02_coins: Ach02Coins
var ach_03_health: Ach03Health
var ach_04_swift: Ach04Swift

func _ready():
	ach_01_die = Ach01Die.new()
	add_child(ach_01_die)
	ach_02_coins = Ach02Coins.new()
	add_child(ach_02_coins)
	ach_03_health = Ach03Health.new()
	add_child(ach_03_health)
	ach_04_swift = Ach04Swift.new()
	add_child(ach_04_swift)
