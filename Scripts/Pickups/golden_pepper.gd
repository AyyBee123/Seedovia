class_name golden_pepper extends pickup_item_class

@export var amount: float = 0.1

func _ready():
	description = "+" + str(amount) + " Seed Size"

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Weapon_Size", "+", amount)
