extends Node

var player
var chance: float: set = set_chance, get = get_chance

func _ready():
	player = Targets.get_player()
	randomize()

func get_chance() -> float:
	return chance

func set_chance(_chance: float) -> void:
	chance = _chance

func chance_to_trigger(weapon = null):
	var random_value = randf()
	var probability = max(min(get_chance(), 1), 0) # 0 <= probability value <= 1
	
	if random_value < probability:
		trigger(weapon)

func trigger(weapon = null): # call this in sub-classes to trigger whatever that sub-class wants to do
	pass
