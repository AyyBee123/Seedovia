extends "res://Scripts/Passives/Classes/passive_chance.gd"

func _ready():
	super._ready()
	chance = 0.2
	player.weapon_fired.connect(chance_to_trigger)

func trigger(weapon = null):
	if weapon == null:
		return
	# seed repeats after 1/(<current fire rate> x2)
	await get_tree().create_timer(1.0 / (weapon.FIRE_RATE * 2), false).timeout
	var weapon_instance = PlayerSeeds.get_weapon(0).instantiate()
	var location = player.hand.global_position
	weapon_instance.initial_weapon = true
	weapon_instance.slot_index = 0
	weapon_instance.source = player
	weapon_instance.seed_slot_number = PlayerSeeds.seed_indices[0]
	weapon_instance.desired_direction = location.direction_to(player.weapon_direction_marker.global_position)
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = location
	player.weapon_fired.emit(weapon_instance)
	player.seed_fired.emit(weapon_instance)
