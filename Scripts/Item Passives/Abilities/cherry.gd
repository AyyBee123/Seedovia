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
	var weapon_instance = weapon.duplicate()
	var location
	if "hand" in source:
		location = source.hand.global_position
	else:
		location = source.global_position
	weapon_instance.add_to_group("Cherry Fired")
	weapon_instance.initial_weapon = weapon.initial_weapon
	weapon_instance.previous_weapon = source
	weapon_instance.slot_index = 0
	weapon_instance.source = player
	weapon_instance.seed_slot_number = weapon.seed_slot_number
	if "weapon_direction_marker" in source:
		weapon_instance.desired_direction = location.direction_to(source.weapon_direction_marker.global_position)
	else:
		weapon_instance.desired_direction = weapon.desired_direction
	# seed repeats after 1/(<current fire rate> x2)
	await get_tree().create_timer(1.0 / (weapon.FIRE_RATE * 2), false).timeout
	if not weapon_instance:
		return
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = location
	source.weapon_fired.emit(weapon_instance)
	if source == player:
		source.seed_fired.emit(weapon_instance)
