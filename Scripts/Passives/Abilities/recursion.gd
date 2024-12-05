extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

var first_weapon = null
var source_passives
var source

func _ready():
	super._ready()
	source = get_parent().get_parent()
	source_passives = source.get_node("Passives").get_children()
	slot_number = 2
	source.weapon_fired.connect(transfer_passive)

func get_slot_number(weapon = null):
	super.get_slot_number(weapon)

func trigger(weapon = null):
	pass

func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	if weapon.seed_slot_number == 2:
		weapon.slot_index -= 1
	else:
		weapon.get_node("Passives").add_child(self.duplicate())
	source_passives = source.get_node("Passives").get_children()
