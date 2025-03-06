extends Node

var player
# use either variable depending on the number of slots that will be modified
var slot_numbers: Array[int] # slot numbers are either 0, 1, or 2; depending on the seed slots that will be modified
var slot_number: int = -1 # slot number is either 0, 1, or 2; depending on the seed slot that will be modified

func _ready():
	player = Targets.get_player()
	player.weapon_fired.connect(get_slot_number)

func get_slot_number(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Seed"):
		if slot_numbers.size() > 0:
			for i in slot_numbers:
				if i == weapon.seed_slot_number:
					trigger(weapon)
		if slot_number == weapon.seed_slot_number:
			trigger(weapon)
		weapon.weapon_fired.connect(get_slot_number)

func trigger(weapon):
	pass
