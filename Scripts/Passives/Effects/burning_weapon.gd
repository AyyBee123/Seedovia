extends Node

@onready var weapon := get_parent()
@onready var resource_preloader := $ResourcePreloader

var duration: float = 4 # duration of the burn, in seconds
var tick: float = 1 # cooldown between each burn damage tick, in seconds
var damage: float

var burning

func _ready():
	burning = resource_preloader.get_resource("Burning").instantiate()
	burning.duration = duration
	burning.tick = tick
	burning.damage = damage
	weapon.has_collided.connect(trigger)

func trigger(object):
	if object.is_in_group("Enemies"):
		object.get_parent().get_node("Burn Stacks").add_child(burning)
