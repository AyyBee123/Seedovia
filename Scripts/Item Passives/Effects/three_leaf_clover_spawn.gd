extends Node

const NUMBER_OF_SEEDS = 2
const MODIFIED_DAMAGE_MULTI = 0.5
const MODIFIED_SIZE_MULTI = 0.75

var SEPARATION_AMOUNT: float

var seed
var weapon
var source

func _ready():
	seed = get_parent().get_parent()
	SEPARATION_AMOUNT = 24 * seed.scale.y
	for i in range(NUMBER_OF_SEEDS):
		var duplicate_seed = PlayerSeeds.get_weapon(0).instantiate()
		duplicate_seed.desired_direction = seed.desired_direction
		duplicate_seed.source = source
		duplicate_seed.previous_weapon = source
		duplicate_seed.transferred_size_multiplier *= MODIFIED_SIZE_MULTI * weapon.transferred_size_multiplier
		duplicate_seed.transferred_damage_multiplier *= MODIFIED_DAMAGE_MULTI * weapon.transferred_damage_multiplier
		duplicate_seed.add_to_group("Clover Seed")
		duplicate_seed.modulate.a = weapon.modulate.a
		get_tree().current_scene.add_child(duplicate_seed)
		if i == 0:
			duplicate_seed.global_position = seed.global_position \
					- seed.desired_direction.rotated(PI/2).normalized() * SEPARATION_AMOUNT
		elif i == 1:
			duplicate_seed.global_position = seed.global_position \
					- seed.desired_direction.normalized().rotated(-PI/2) * SEPARATION_AMOUNT
		source.weapon_fired.emit(duplicate_seed)
