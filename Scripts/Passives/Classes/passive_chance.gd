extends Node

@onready var player := $"../.."
var chance: float

func _ready():
	randomize()

func get_chance(base_chance: float) -> float:
	return player._player_stats.stats["Luck"]["x"] * ((base_chance * 100) + player._player_stats.stats["Luck"]["+"]) / 100
	
func chance_to_trigger():
	var random_value = randf()
	var probability = max(min(get_chance(chance), 1), 0) # 0 <= probability value <= 1
	
	if random_value < probability:
		trigger()
		
func trigger(): # call this in sub-classes to trigger whatever that sub-class wants to do
	pass
