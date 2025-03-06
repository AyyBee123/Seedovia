extends Node

var source

func _ready():
	source = get_parent().get_parent()
	if source.is_in_group("Do Not Recur"):
		source.next_weapon = null
	else:
		source.next_weapon = PlayerInventory.seeds.get(2).scene
	source.set_next_seed_slot_number = 2
	source.weapon_fired.connect(do_not_recur)

func do_not_recur(weapon):
	weapon.add_to_group("Do Not Recur")
