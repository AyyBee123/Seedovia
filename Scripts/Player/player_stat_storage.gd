extends Node

@onready var player = get_tree().get_nodes_in_group("Players")[0] # keeps returning null, so I added it to the setget
var stats: Dictionary
var current_health: int

func get_stats():
	player = get_tree().get_nodes_in_group("Players")[0]
	stats = player._player_stats.stats
	current_health = player._player_stats.health
	return stats

func set_stats():
	player = get_tree().get_nodes_in_group("Players")[0]
	player._player_stats.stats = stats
	player._player_stats.health = current_health
	
