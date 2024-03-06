extends Node

var tally_count := 0
@onready var player := $"../.."

func _ready():
	player.weapon_fired.connect(add_tally)

func add_tally():
	if self.get_children().size() > 0:
		tally_count += 1
	return
