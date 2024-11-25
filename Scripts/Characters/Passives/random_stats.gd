extends Node

var player

func _ready():
	player = get_parent().get_parent()
	
	player._player_stats.max_health = Global.RNG.randi_range(1, 4)
	player._player_stats.health = player._player_stats.max_health
	player._player_stats.overcapped_health = player._player_stats.max_health
	player._player_stats.speed = Global.RNG.randf_range(250, 400)
	player._player_stats.dash_rate = Global.RNG.randf_range(0.8, 1.2)
	player._player_stats.dash_distance = Global.RNG.randf_range(1850, 2250)
	player._player_stats.dash_invulnerability = 0.25
	player._player_stats.fire_rate = Global.RNG.randf_range(6, 15)
	player._player_stats.contact_damage = 0.0
	player._player_stats.invulnerability_time = 1.0
	player._player_stats.acceleration = 0.2
	player._player_stats.friction = 0.5
	player._player_stats.luck = Global.RNG.randf_range(-1, 1)
	player._player_stats.weapon_speed = Global.RNG.randf_range(400, 600)
	player._player_stats.weapon_range = Global.RNG.randf_range(25, 55)
	player._player_stats.weapon_size = Global.RNG.randf_range(0.8, 1.2)
	player._player_stats.weapon_damage = Global.RNG.randf_range(6, 15)
	player._player_stats.weapon_blast_radius = Global.RNG.randf_range(0.8, 1.2)
	
	player._player_stats.initialize_base_stats()
	
	get_parent().remove_child.call_deferred(self)
	queue_free.call_deferred()
