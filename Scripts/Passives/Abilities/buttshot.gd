extends "res://Scripts/Passives/Classes/passive_chance.gd"

var source

func _ready():
	# first get_parent is the Passives node, second get_parent is the object node (player)
	super._ready()
	source = get_parent().get_parent()
	chance = 0.5
	source.weapon_fired.connect(chance_to_trigger)

func trigger(weapon = null):
	if weapon.is_in_group("Buttshot Weapon"): # prevent duplicates
		return
	if weapon == null:
		return
	if not weapon.is_in_group("Seed"):
		return
	var duplicate_seed = weapon.duplicate()
	duplicate_seed.desired_direction = -weapon.desired_direction
	duplicate_seed.slot_index = weapon.slot_index
	duplicate_seed.previous_weapon = source
	duplicate_seed.seed_slot_number = weapon.seed_slot_number
	duplicate_seed.source = Targets.get_player()
	duplicate_seed.add_to_group("Buttshot Weapon")
	duplicate_seed.modulate.a = weapon.modulate.a
	duplicate_seed.transferred_speed_multiplier *= weapon.transferred_speed_multiplier
	duplicate_seed.transferred_range_multiplier *= weapon.transferred_range_multiplier
	duplicate_seed.transferred_size_multiplier *= weapon.transferred_size_multiplier
	duplicate_seed.transferred_damage_multiplier *= weapon.transferred_damage_multiplier
	duplicate_seed.transferred_blast_radius_multiplier *= weapon.transferred_blast_radius_multiplier
	duplicate_seed.transferred_fire_rate_multiplier *= weapon.transferred_fire_rate_multiplier
	get_tree().current_scene.add_child(duplicate_seed)
	duplicate_seed.global_position = source.global_position - weapon.desired_direction * 15
	source.weapon_fired.emit(duplicate_seed)
