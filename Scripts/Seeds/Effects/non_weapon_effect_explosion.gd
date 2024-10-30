extends "res://Scripts/Passives/Effects/explosion.gd"

var previous_weapon = null

func _ready():
	super._ready()
	if previous_weapon:
		previous_weapon.weapon_fired.emit(self)
