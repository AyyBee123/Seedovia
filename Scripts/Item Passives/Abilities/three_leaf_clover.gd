extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

var source
const THREE_LEAF_CLOVER_SPAWN = preload("res://Scenes/Item Passives/Effects/Three Leaf Clover Spawn.tscn")

func _ready():
	source = get_parent().get_parent()
	slot_number = 0
	super._ready()
	source.weapon_fired.connect(get_slot_number)

func trigger(weapon = null):
	if weapon.is_in_group("Clover Seed"):
		return
	var clover = THREE_LEAF_CLOVER_SPAWN.instantiate()
	clover.source = source
	clover.weapon = weapon
	weapon.get_node("Passives").add_child(clover)
