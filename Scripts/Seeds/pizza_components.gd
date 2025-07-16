extends "res://Scripts/Seeds/seed_template.gd"

const TOMATO = preload("res://Scenes/Seeds/Tomato.tscn")
const CHEESE = preload("res://Scenes/Seeds/Cheese.tscn")
const HERB = preload("res://Scenes/Seeds/Herb.tscn")
const MUSHROOM = preload("res://Scenes/Seeds/Mushroom.tscn")
const SAUSAGE = preload("res://Scenes/Seeds/Sausage.tscn")

var random_seed
var components: Array

func _ready():
	components.append(TOMATO)
	components.append(CHEESE)
	components.append(HERB)
	components.append(MUSHROOM)
	components.append(SAUSAGE)
	
	super._ready()
	shoot_seed()

func shoot_seed():
	var seed = components.pick_random().instantiate()
	set_weapon_properties(seed, desired_direction, ignore_first_collision, hit_enemy)
	seed_spawned.emit(seed)
	destroy()

func set_weapon_properties(weapon, _desired_direction, _ignore_first_collision = false, _enemy = null):
	weapon.initial_weapon = false
	weapon.ignore_first_collision = _ignore_first_collision
	weapon.desired_direction = _desired_direction
	weapon.source = source
	weapon.previous_weapon = previous_weapon
	weapon.hit_enemy = _enemy
	if set_next_seed_slot_index:
		weapon.slot_index = set_next_seed_slot_index
	else:
		weapon.slot_index = slot_index
	weapon.transferred_speed_multiplier *= transferred_speed_multiplier
	weapon.transferred_range_multiplier *= transferred_range_multiplier
	weapon.transferred_size_multiplier *= transferred_size_multiplier
	weapon.transferred_damage_multiplier *= transferred_damage_multiplier
	weapon.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
	weapon.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
	weapon.modulate = modulate
	if set_next_seed_slot_number:
		weapon.seed_slot_number = set_next_seed_slot_number
	else:
		weapon.seed_slot_number = seed_slot_number
	initialize_location.call_deferred(weapon)

func initialize_location(weapon):
	if not get_tree():
		return
	weapon.remove_child(weapon.get_node("Passives"))
	weapon.add_child(get_node("Passives").duplicate())
	weapon.remove_child(weapon.get_node("Visual Effects"))
	weapon.add_child(get_node("Visual Effects").duplicate())
	get_tree().current_scene.add_child(weapon)
	weapon.global_position = global_position
