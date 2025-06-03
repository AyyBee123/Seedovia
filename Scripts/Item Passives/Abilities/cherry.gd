extends "res://Scripts/Passives/Classes/passive_chance.gd"

var source

func _ready():
	source = get_parent().get_parent()
	super._ready()
	chance = 0.2
	source.weapon_fired.connect(chance_to_trigger)

func trigger(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Cherry Fired"):
		return
	if source.is_in_group("Direct Fire"):
		return
	var weapon_instance = weapon.duplicate()
	var location
	if "hand" in source:
		location = source.hand.global_position
	else:
		location = source.global_position
	weapon_instance.add_to_group("Cherry Fired")
	weapon_instance.initial_weapon = true
	weapon_instance.previous_weapon = source
	weapon_instance.slot_index = 0
	weapon_instance.source = player
	weapon_instance.seed_slot_number = weapon.seed_slot_number
	weapon_instance.desired_direction = location.direction_to(source.weapon_direction_marker.global_position)
	weapon_instance.transferred_speed_multiplier *= weapon.transferred_speed_multiplier
	weapon_instance.transferred_range_multiplier *= weapon.transferred_range_multiplier
	weapon_instance.transferred_size_multiplier *= weapon.transferred_size_multiplier
	weapon_instance.transferred_damage_multiplier *= weapon.transferred_damage_multiplier
	weapon_instance.transferred_blast_radius_multiplier *= weapon.transferred_blast_radius_multiplier
	weapon_instance.transferred_fire_rate_multiplier *= weapon.transferred_fire_rate_multiplier
	# seed repeats after 1/(<current fire rate> x2)
	await get_tree().create_timer(1.0 / (weapon.FIRE_RATE * 2), false).timeout
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = location
	source.weapon_fired.emit(weapon_instance)
	if source == player:
		source.seed_fired.emit(weapon_instance)
