extends "res://Scripts/Passives/Classes/passive_tally.gd"

func _ready():
	tally_count = 0
	player = get_parent().get_parent()
	player.weapon_fired.connect(add_tally)

func add_tally(weapon = null):
	tally_count += 1
	if tally_count >= 5:
		tally_count = 0
		if player == Targets.get_player():
			player.dashed.emit()
