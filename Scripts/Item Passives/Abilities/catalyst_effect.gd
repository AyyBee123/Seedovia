extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

var source

func _ready():
	slot_numbers = [0, 1, 2]
	source = get_parent().get_parent()
	source.weapon_fired.connect(get_slot_number)
	super._ready()

func trigger(weapon):
	weapon.BASE_DAMAGE += 2
