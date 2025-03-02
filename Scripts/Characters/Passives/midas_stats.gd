extends Node

var player

func set_stats():
	player = get_parent()
	
	player._player_stats.max_health = 3
	player._player_stats.leaf_hearts = 0
	player._player_stats.speed = 300.0
	player._player_stats.dash_rate = 1.0
	player._player_stats.dash_distance = 2000.0
	player._player_stats.dash_invulnerability = 0.25
	player._player_stats.contact_damage = 0.0
	player._player_stats.invulnerability_time = 1.0
	player._player_stats.acceleration = 0.2
	player._player_stats.friction = 0.5
	player._player_stats.luck = 0.0
	
	player._player_stats.stats["Fire_Rate"]["x"] = 0.8
	player._player_stats.stats["Weapon_Speed"]["x"] = 0.8
	player._player_stats.stats["Weapon_Range"]["x"] = 0.8
	player._player_stats.stats["Weapon_Size"]["x"] = 0.8
	player._player_stats.stats["Weapon_Damage"]["x"] = 0.8
	player._player_stats.stats["Weapon_Blast_Radius"]["x"] = 0.8
	
	player._player_stats.initialize_base_stats()
