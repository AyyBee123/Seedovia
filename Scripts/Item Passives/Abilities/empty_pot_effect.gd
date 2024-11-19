extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

func _ready():
	slot_number = 0
	super._ready()

func trigger(weapon):
	weapon.damage_multiplier *= 1.2
