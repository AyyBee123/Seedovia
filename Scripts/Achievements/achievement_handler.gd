extends Node

var ach_01_die: Ach01Die
var ach_02_coins: Ach02Coins
var ach_03_health: Ach03Health
var ach_04_swift: Ach04Swift
var ach_05_pizza: Ach05Pizza
var ach_06_veapea: Ach06VeaPea
var ach_07_blueberry: Ach07Blueberry
var ach_08_goldbasket: Ach08GoldBasket

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
	ach_06_veapea = Ach06VeaPea.new()
	add_child(ach_06_veapea)
	ach_07_blueberry = Ach07Blueberry.new()
	add_child(ach_07_blueberry)
	ach_08_goldbasket = Ach08GoldBasket.new()
	add_child(ach_08_goldbasket)
