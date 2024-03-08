extends "res://Scripts/Passives/Classes/passive_chance.gd"

var weapon

enum status_effect {
	FIRE,
	CHILL,
	POISON,
	LIGHTNING
}

func ready():
	chance = 0.3
	player.weapon_fired.connect(chance_to_trigger)
	super._ready()

func trigger():
	pass
	
