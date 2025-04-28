extends Node

var seed
var weapon
var source

func _ready():
	seed = get_parent().get_parent()
	var duplicate_seed = PlayerSeeds.load_weapons()[0].instantiate()
	duplicate_seed.desired_direction = -seed.desired_direction
	duplicate_seed.transferred_size_multiplier *= weapon.transferred_size_multiplier
	duplicate_seed.transferred_damage_multiplier *= weapon.transferred_damage_multiplier
	duplicate_seed.slot_index = 0
	duplicate_seed.previous_weapon = source
	duplicate_seed.seed_slot_number = PlayerSeeds.seed_indices[0]
	duplicate_seed.source = source
	duplicate_seed.add_to_group("Buttshot Weapon")
	duplicate_seed.modulate.a = weapon.modulate.a
	get_tree().current_scene.add_child(duplicate_seed)
	duplicate_seed.global_position = source.global_position - seed.desired_direction * 15
	source.weapon_fired.emit(duplicate_seed)
