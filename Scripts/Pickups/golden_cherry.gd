class_name golden_cherry extends pickup_item_class

@export var amount: float = 5

func _ready():
	category = "STAT UP"
	description = "+" + str(amount) + "% Fire Rate"

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Fire_Rate", "+", amount / 100)
	player.spawn_stat_increase(amount, "Fire Rate")
