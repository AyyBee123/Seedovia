extends Node

var player

func _ready():
	player = get_parent().get_parent()
	
	player._player_stats.max_health = 4
	player._player_stats.health = player._player_stats.max_health
	player._player_stats.overcapped_health = player._player_stats.max_health
	player._player_stats.speed = 250.0
	player._player_stats.dash_rate = 1.05
	player._player_stats.dash_distance = 1850.0
	player._player_stats.dash_invulnerability = 0.25
	player._player_stats.fire_rate = 7.5
	player._player_stats.contact_damage = 0.0
	player._player_stats.invulnerability_time = 1.0
	player._player_stats.acceleration = 0.1
	player._player_stats.friction = 0.25
	player._player_stats.luck = 0.0
	player._player_stats.weapon_speed = 400.0
	player._player_stats.weapon_range = 100.0
	player._player_stats.weapon_size = 1.1
	player._player_stats.weapon_damage = 8.0
	player._player_stats.weapon_blast_radius = 1.15
	
	player._player_stats.initialize_base_stats()
	
	get_parent().remove_child(self)
	queue_free.call_deferred()
