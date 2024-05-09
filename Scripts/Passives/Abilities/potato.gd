extends "res://Scripts/Passives/Classes/passive_chance.gd"

func _ready():
	chance = 1
	player.dashed.connect(chance_to_trigger)
	super._ready()

func trigger(weapon = null):
	var potato
