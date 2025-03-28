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
	var seed = PlayerSeeds.load_weapons()[0].instantiate()
	seed.desired_direction = -weapon.desired_direction
	seed.initial_weapon = true
	seed.slot_index = 0
	seed.previous_weapon = source
	seed.seed_slot_number = PlayerSeeds.seed_indices[0]
	seed.source = source
	seed.add_to_group("Buttshot Weapon")
	get_tree().current_scene.add_child(seed)
	seed.global_position = player.hand.global_position + seed.desired_direction * 20
	source.weapon_fired.emit(seed)
