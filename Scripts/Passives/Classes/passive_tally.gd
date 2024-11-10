extends Node

var tally_count := 0
var player
var source

func _ready():
	player = Targets.get_player()
	tally_count = 0
	source = get_parent().get_parent()
	source.weapon_fired.connect(add_tally)

func add_tally(weapon = null):
	tally_count += 1
	return
