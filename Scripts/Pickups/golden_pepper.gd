class_name golden_pepper extends pickup_item_class

@export var amount: float = 5

func _ready():
	category = "STAT UP"
	description = "+" + str(amount) + "% Seed Size"

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Weapon_Size", "+", amount / 100)
	Game.audio_manager.play(Game.audio_manager.use)
	player.spawn_stat_increase(amount, "Seed Size")
