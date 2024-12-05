extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

var source
const THREE_LEAF_CLOVER_SPAWN = preload("res://Scenes/Item Passives/Effects/Three Leaf Clover Spawn.tscn")

func _ready():
	source = get_parent().get_parent()
	slot_number = 0
	super._ready()

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null or weapon.is_in_group("Weapon Effect"):
		return
	# make a new swarm passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(self.duplicate())

func trigger(weapon = null):
	var clover = THREE_LEAF_CLOVER_SPAWN.instantiate()
	weapon.get_node("Passives").add_child(clover)
