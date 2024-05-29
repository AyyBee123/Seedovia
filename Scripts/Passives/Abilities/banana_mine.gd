extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader := $ResourcePreloader

@export var damage_multiplier: float = 1.5
@export var speed_multiplier: float = 1
var source

func _ready():
	# first get_parent is the Passives node, second get_parent is the object node (player or ally)
	source = get_parent().get_parent()
	chance = 0.25
	source.weapon_fired.connect(chance_to_trigger)
	source.weapon_fired.connect(transfer_passive)
	super._ready()
	
# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null or weapon.is_in_group("Weapon Effect"):
		return
	# make a new banana mine passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(duplicate())

func trigger(weapon = null):
	var banana = resource_preloader.get_resource("Banana").instantiate()
	banana.source_pos = source.global_position
	banana.weapon_direction = source.weapon_direction
	banana.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
	banana.speed = player._player_stats.get_stat("Weapon_Speed") * speed_multiplier
	banana.explosion_size = player._player_stats.get_stat("Weapon_Blast_Radius")
	get_tree().current_scene.add_child.call_deferred(banana)
