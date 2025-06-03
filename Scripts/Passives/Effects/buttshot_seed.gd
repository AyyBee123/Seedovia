extends Node

var source

func _ready():
	var seed = get_parent().get_parent()
	if seed == null:
		return
	if not seed.is_in_group("Seed"):
		return
	var duplicate_seed = seed.duplicate()
	duplicate_seed.desired_direction = -seed.desired_direction
	duplicate_seed.slot_index = seed.slot_index
	duplicate_seed.previous_weapon = source
	duplicate_seed.seed_slot_number = seed.seed_slot_number
	duplicate_seed.source = Targets.get_player()
	duplicate_seed.add_to_group("Buttshot Weapon")
	duplicate_seed.modulate.a = seed.modulate.a
	duplicate_seed.transferred_speed_multiplier *= seed.transferred_speed_multiplier
	duplicate_seed.transferred_range_multiplier *= seed.transferred_range_multiplier
	duplicate_seed.transferred_size_multiplier *= seed.transferred_size_multiplier
	duplicate_seed.transferred_damage_multiplier *= seed.transferred_damage_multiplier
	duplicate_seed.transferred_blast_radius_multiplier *= seed.transferred_blast_radius_multiplier
	duplicate_seed.transferred_fire_rate_multiplier *= seed.transferred_fire_rate_multiplier
	get_tree().current_scene.add_child(duplicate_seed)
	duplicate_seed.global_position = source.global_position - seed.desired_direction * 15
	source.weapon_fired.emit(duplicate_seed)
