extends Node

var player

func _ready():
	player = Targets.get_player()

func trigger(weapon = null): # call this in sub-classes to trigger whatever that sub-class wants to do
	pass
