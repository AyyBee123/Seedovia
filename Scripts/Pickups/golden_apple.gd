class_name golden_apple extends pickup_item_class

@export var amount: float = 10

func _ready():
	category = "STAT UP"
	description = "+" + str(amount) + "% Damage"

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Weapon_Damage", "+", amount / 100)
	player.spawn_stat_increase(amount, "Damage")
