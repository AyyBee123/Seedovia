extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader := $ResourcePreloader

var source
var collided_object
var burning

var duration: float = 4 # duration of the burn, in seconds
var tick: float = 1 # tick rate, in seconds
var damage: float # damage of each burn tick

var color = Color("dc4515")

func _ready():
	source = get_parent().get_parent()
	chance = 0.3
	source.weapon_fired.connect(chance_to_trigger)
	super._ready()

func trigger(weapon = null):
	var fire_effect = resource_preloader.get_resource("Burning Weapon").instantiate()
	if weapon.modulate == Color.WHITE:
		weapon.modulate *= color
	else:
		weapon.modulate += color
	transfer_passive(fire_effect, weapon)

func transfer_passive(fire_effect, weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	weapon.get_node("Passives").add_child(fire_effect)
