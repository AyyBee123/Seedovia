extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

const RECURING_SEED = preload("res://Scenes/Passives/Effects/Recuring Seed.tscn")

var first_weapon = null
var source

func _ready():
	super._ready()
	source = get_parent().get_parent()
	slot_number = 2
	source.weapon_fired.connect(transfer_passive)

func get_slot_number(weapon = null):
	super.get_slot_number(weapon)

func trigger(weapon = null):
	if not weapon.is_in_group("Seed"):
		return
	weapon.get_node("Passives").add_child(RECURING_SEED.instantiate())

func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	if not weapon.is_in_group("Seed"):
		return
	if weapon.is_in_group("Do Not Recur"):
		return
	else:
		weapon.get_node("Passives").add_child(self.duplicate())
