extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader := $ResourcePreloader

@export var damage_multiplier: float = 1.25
@export var speed_multiplier: float = 1
var source
var source_passives: Array

func _ready():
	# first get_parent is the Passives node, second get_parent is the object node (player or ally)
	super._ready()
	source = get_parent().get_parent()
	chance = 0.25
	source.weapon_fired.connect(chance_to_trigger)
	source.weapon_fired.connect(transfer_passive)

func banana_mine():
	pass

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	# make a new banana mine passive and add it as a child of the next weapon
	if weapon.has_method("banana"):
		return
	weapon.get_node("Passives").add_child(self.duplicate())

func trigger(weapon = null):
	var banana = resource_preloader.get_resource("Banana").instantiate()
	banana.DAMAGE = 5 * (1 + player._player_stats.stats["Weapon_Damage"]["+"]) \
			* player._player_stats.stats["Weapon_Damage"]["x"]
	banana.speed = 250 * (1 + player._player_stats.stats["Weapon_Speed"]["+"]) \
			* player._player_stats.stats["Weapon_Speed"]["x"]
	banana.previous_weapon = source
	banana.source_pos = source.global_position
	banana.weapon_direction = source.weapon_direction
	banana.damage_multiplier = damage_multiplier
	banana.BLAST_RADIUS = 1
	get_tree().current_scene.add_child.call_deferred(banana)
