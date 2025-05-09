class_name golden_strawberry extends pickup_item_class

@export var amount: float = 10

func _ready():
	category = "STAT UP"
	description = "+" + str(amount) + "% Range"

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Weapon_Range", "+", amount / 100)
	player.spawn_stat_increase(amount, "Range")
