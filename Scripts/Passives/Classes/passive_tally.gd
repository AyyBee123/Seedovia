extends Node

var tally_count := 0
@onready var player := $"../.."
var source

func _ready():
	tally_count = 0
	source = get_parent().get_parent()
	source.weapon_fired.connect(add_tally)

func add_tally(weapon = null):
	tally_count += 1
	return
