extends Node

var player

func _ready():
	player = get_parent()
	
	player._player_stats.max_health = 3
	player._player_stats.health = player._player_stats.max_health
	player._player_stats.overcapped_health = player._player_stats.max_health
	player._player_stats.speed = 300.0
	player._player_stats.dash_rate = 1.0
	player._player_stats.dash_distance = 2000.0
	player._player_stats.dash_invulnerability = 0.25
	player._player_stats.fire_rate = 10.0
	player._player_stats.contact_damage = 0.0
	player._player_stats.invulnerability_time = 1.0
	player._player_stats.acceleration = 0.1
	player._player_stats.friction = 0.25
	player._player_stats.luck = 0.0
	player._player_stats.weapon_speed = 500.0
	player._player_stats.weapon_range = 70.0
	player._player_stats.weapon_size = 1.0
	player._player_stats.weapon_damage = 10.0
	player._player_stats.weapon_blast_radius = 1.0
	
	player._player_stats.initialize_base_stats()
