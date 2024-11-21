extends "res://Scripts/Passives/Classes/passive_trigger.gd"

@onready var resource_preloader = $ResourcePreloader

# put a dictionary with a seed as a key and a seed as the value to avoid cross chaining
var source
var tick_rate = 0.2

func _ready():
	source = get_parent().get_parent()
	source.weapon_fired.connect(trigger)
	super._ready()

func trigger(weapon = null):
	var prickle = resource_preloader.get_resource("Prickle").instantiate()
	prickle.damage = player._player_stats.get_stat("Weapon_Damage") * weapon.damage_multiplier
	prickle.size_multiplier = player._player_stats.get_stat("Weapon_Size")
	prickle.weapon = weapon
	prickle.tick_rate = tick_rate
	weapon.add_child.call_deferred(prickle)
	transfer_passive(weapon)

func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	weapon.get_node("Passives").add_child(self.duplicate())
