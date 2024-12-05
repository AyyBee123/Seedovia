extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

const LUNACY_S_DELIGHT_PROJECTILE = \
		preload("res://Scenes/Item Passives/Effects/Lunacy's Delight Projectile Spawner.tscn")
var source_passives
var source

func _ready():
	source = get_parent().get_parent()
	slot_numbers = [1, 2]
	super._ready()

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null or weapon.is_in_group("Weapon Effect"):
		return
	# make a new swarm passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(self.duplicate())

func trigger(weapon = null):
	var proj = LUNACY_S_DELIGHT_PROJECTILE.instantiate()
	weapon.get_node("Passives").add_child(proj)
