extends "res://Scripts/Passives/Classes/passive_trigger.gd"

@onready var resource_preloader = $ResourcePreloader

# put a dictionary with a seed as a key and a seed as the value to avoid cross chaining
var source

func _ready():
	source = get_parent().get_parent()
	source.weapon_fired.connect(trigger)
	super._ready()

func trigger(weapon = null):
	var prickle = resource_preloader.get_resource("Prickle").instantiate()
	weapon.get_node("Passives").add_child.call_deferred(prickle)
	transfer_passive(weapon)

func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	weapon.get_node("Passives").add_child(self.duplicate())
