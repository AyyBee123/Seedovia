extends Node

var ach_01_die: Ach01Die
var ach_02_coins: Ach02Coins

func _ready():
	ach_01_die = Ach01Die.new()
	add_child(ach_01_die)
	ach_02_coins = Ach02Coins.new()
	add_child(ach_02_coins)
