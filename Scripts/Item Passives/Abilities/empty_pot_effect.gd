extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

func _ready():
	slot_number = 0
	super._ready()

func trigger(weapon):
	weapon.BASE_DAMAGE *= 1.2
