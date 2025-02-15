class_name golden_coffee_bean extends pickup_item_class

@export var speed_amount: float = 25
@export var dash_rate_amount: float = 0.05

func _ready():
	description = "+" + str(speed_amount) + " Movement Speed" + "\n" \
			+ "-" + str(dash_rate_amount) + " Dash Rate"

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Speed", "+", speed_amount)
	player._player_stats.set_stat("Dash_Rate", "-", dash_rate_amount)
