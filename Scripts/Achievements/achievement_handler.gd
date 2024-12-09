extends Node

var ach_01_die: Ach01Die

func _ready():
	ach_01_die = Ach01Die.new()
	add_child(ach_01_die)
	
