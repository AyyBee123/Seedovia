extends "res://Scripts/Passives/Classes/passive_chance.gd"

const DOUBLE_UP_PARTICLES = preload("res://Scenes/Passives/Effects/Double Up Particles.tscn")
const DOUBLE_UP_VFX = preload("res://Scenes/Passives/Effects/Double Up VFX.tscn")

var source
var collided_object

func _ready():
	chance = 0.3
	super._ready()
	source = get_parent().get_parent()
	source.weapon_fired.connect(chance_to_trigger)
	source.weapon_fired.connect(transfer_passive)

func collide(object):
	collided_object = object
	trigger(source)

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	# make a new double up passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(self.duplicate())

func trigger(weapon = null):
	if not weapon.get_node("Visual Effects").get_node_or_null("Double Up Particles"):
		weapon.get_node("Visual Effects").add_child(DOUBLE_UP_PARTICLES.instantiate())
	weapon.get_node("Passives").add_child(DOUBLE_UP_VFX.instantiate())
	if "BASE_DAMAGE" in weapon:
		weapon.BASE_DAMAGE *= 2
	elif "DAMAGE" in weapon:
		weapon.DAMAGE *= 2
	elif "damage" in weapon:
		weapon.damage *= 2
