extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader := $ResourcePreloader

var damage_multiplier := 0.5
var source
var collided_object
var burning

var duration: float = 4 # duration of the burn, in seconds
var tick: float = 1 # tick rate, in seconds
var damage: float # damage of each burn tick

func _ready():
	source = get_parent().get_parent()
	chance = 0.3
	source.weapon_fired.connect(chance_to_trigger)
	super._ready()

func collide(object):
	if object.is_in_group("Enemies"):
		burning = resource_preloader.get_resource("Burning").instantiate()
		burning.duration = duration
		burning.tick = tick
		burning.damage = source.DAMAGE
		object.get_parent().get_node("Burn Stacks").add_child(burning)

func trigger(weapon = null):
	var fire_effect = resource_preloader.get_resource("Burning Weapon").instantiate()
	if weapon.modulate == Color.WHITE:
		weapon.modulate *= Color.DARK_ORANGE
	else:
		weapon.modulate += Color.DARK_ORANGE
	weapon.has_collided.connect(collide)
	fire_effect.damage = source.DAMAGE
	transfer_passive(weapon)

func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	weapon.get_node("Passives").add_child(self.duplicate())
