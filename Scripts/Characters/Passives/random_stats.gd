extends Node

var player

func _ready():
	player = get_parent().get_parent()
	
	player._player_stats.max_health = Global.RNG.randi_range(1, 4)
	player._player_stats.speed = Global.RNG.randf_range(250, 400)
	player._player_stats.dash_rate = Global.RNG.randf_range(0.8, 1.2)
	player._player_stats.dash_distance = Global.RNG.randf_range(1850, 2250)
	player._player_stats.fire_rate = Global.RNG.randf_range(6, 15)
	player._player_stats.luck = Global.RNG.randf_range(-1, 1)
	player._player_stats.weapon_speed = Global.RNG.randf_range(400, 600)
	player._player_stats.weapon_range = Global.RNG.randf_range(50, 110)
	player._player_stats.weapon_size = Global.RNG.randf_range(0.8, 1.2)
	player._player_stats.weapon_damage = Global.RNG.randf_range(6, 15)
	player._player_stats.weapon_blast_radius = Global.RNG.randf_range(0.8, 1.2)
	
	player._player_stats.initialize_base_stats()
	
	get_parent().remove_child(self)
	queue_free.call_deferred()
