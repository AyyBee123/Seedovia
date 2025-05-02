class_name golden_carrot extends pickup_item_class

@export var amount: float = 10

func _ready():
	category = "STAT UP"
	description = "+" + str(amount) + "% Seed Speed"

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Weapon_Speed", "+", amount / 100)
