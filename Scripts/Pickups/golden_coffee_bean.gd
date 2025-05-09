class_name golden_coffee_bean extends pickup_item_class

@export var amount: float = 25

func _ready():
	category = "STAT UP"
	description = "+" + str(amount) + " Movement Speed"

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Speed", "+", amount)
	player.spawn_stat_increase(amount, "Move Speed")
