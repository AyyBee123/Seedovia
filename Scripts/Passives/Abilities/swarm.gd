extends "res://Scripts/Passives/Classes/passive_chance.gd"

var source_passives
var source
var damage_multiplier = 3
var speed = 450
var pos

@onready var resource_preloader = $ResourcePreloader

func _ready():
	source = get_parent().get_parent()
	chance = 0.1
	source.weapon_fired.connect(chance_to_trigger)
	source.weapon_fired.connect(transfer_passive)
	super._ready()

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null or weapon.is_in_group("Weapon Effect"):
		return
	# make a new swarm passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(self.duplicate())
	source_passives = source.get_node("Passives").get_children()

func trigger(weapon = null):
	pos = source.global_position
	var bee = resource_preloader.get_resource("Bee").instantiate()
	bee.previous_weapon = source
	bee.source_pos = source.global_position
	bee.weapon_direction = source.weapon_direction
	bee.damage = player._player_stats.get_stat("Weapon_Damage")
	bee.damage_multiplier = 3
	bee.speed = speed
	get_tree().current_scene.add_child(bee)
