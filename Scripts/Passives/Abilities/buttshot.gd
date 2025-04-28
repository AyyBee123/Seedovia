extends "res://Scripts/Passives/Classes/passive_chance.gd"

const BUTTSHOT_SEED = preload("res://Scenes/Passives/Effects/Buttshot Seed.tscn")

var source

func _ready():
	# first get_parent is the Passives node, second get_parent is the object node (player)
	super._ready()
	source = get_parent().get_parent()
	chance = 0.5
	source.weapon_fired.connect(chance_to_trigger)

func trigger(weapon = null):
	if weapon.is_in_group("Clover Seed"): # prevent duplicates
		return
	var shot = BUTTSHOT_SEED.instantiate()
	shot.source = source
	shot.weapon = weapon
	weapon.get_node("Passives").add_child(shot)
