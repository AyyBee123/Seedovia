extends "res://Scripts/Passives/Classes/passive_chance.gd"

const BASE_CHANCE = 0.1
const SPREAD = PI/6

var source

func _ready():
	source = get_parent().get_parent()
	super._ready()
	source.weapon_fired.connect(chance_to_trigger)

func _physics_process(delta):
	if player:
		set_chance(BASE_CHANCE * int(player._player_stats.health))

func chance_to_trigger(weapon = null):
	# shoot multiple projectiles if the player reaches 10+ filled red heart
	var random_value = randf()
	var probability = max(get_chance(), 0)
	var guaranteed_triggers = int(probability) # number of guaranteed extra projectiles
	var extra_chance = probability - guaranteed_triggers # remaining fractional chance
	
	# trigger guaranteed times
	for i in guaranteed_triggers:
		trigger(weapon)
	
	# chance to trigger the remaining percent
	if random_value < extra_chance:
		trigger(weapon)

func trigger(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Duplicated Seed"):
		return
	var weapon_instance = weapon.duplicate()
	var location
	if "hand" in source:
		location = source.hand.global_position
	else:
		location = source.global_position
	weapon_instance.add_to_group("Duplicated Seed")
	weapon_instance.initial_weapon = weapon.initial_weapon
	weapon_instance.previous_weapon = source
	weapon_instance.slot_index = 0
	weapon_instance.source = player
	weapon_instance.seed_slot_number = weapon.seed_slot_number
	var angle = randf_range(-SPREAD, SPREAD)
	weapon_instance.desired_direction = weapon.desired_direction.rotated(angle)
	if not weapon_instance:
		return
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = location
	source.weapon_fired.emit(weapon_instance)
