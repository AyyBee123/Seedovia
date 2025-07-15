extends Node

var ach_01_die: Ach01Die
var ach_02_coins: Ach02Coins
var ach_03_health: Ach03Health
var ach_04_swift: Ach04Swift
var ach_05_pizza: Ach05Pizza
var ach_06_veapea: Ach06VeaPea
var ach_07_blueberry: Ach07Blueberry
var ach_08_goldbasket: Ach08GoldBasket
var ach_09_shadeslash: Ach09ShadeSlash
var ach_10_wavyshroom: Ach10WavyShroom
var ach_11_metronome: Ach11Metronome
var ach_12_pizzadisc: Ach12PizzaDisc
var ach_13_whitechaos: Ach13WhiteChaos
var ach_14_sell: Ach14Sell
var ach_15_circleofseeds: Ach15CircleOfSeeds

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
	ach_09_shadeslash = Ach09ShadeSlash.new()
	add_child(ach_09_shadeslash)
	ach_10_wavyshroom = Ach10WavyShroom.new()
	add_child(ach_10_wavyshroom)
	ach_11_metronome = Ach11Metronome.new()
	add_child(ach_11_metronome)
	ach_12_pizzadisc = Ach12PizzaDisc.new()
	add_child(ach_12_pizzadisc)
	ach_13_whitechaos = Ach13WhiteChaos.new()
	add_child(ach_13_whitechaos)
	ach_14_sell = Ach14Sell.new()
	add_child(ach_14_sell)
	ach_15_circleofseeds = Ach15CircleOfSeeds.new()
	add_child(ach_15_circleofseeds)
