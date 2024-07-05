extends Node

@onready var weapon := get_parent()
@onready var resource_preloader := $ResourcePreloader

var duration: float = 4 # duration of the burn, in seconds
var tick: float = 1 # tick rate, in seconds
var damage: float # damage of each burn tick

var burning

func _ready():
	weapon.has_collided.connect(trigger)

func trigger(object):
	if object.is_in_group("Enemies"):
		burning = resource_preloader.get_resource("Burning").instantiate()
		burning.duration = duration
		burning.tick = tick
		burning.damage = damage
		object.get_parent().get_node("Burn Stacks").add_child(burning)
