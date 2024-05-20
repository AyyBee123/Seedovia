extends Node

@onready var player = get_tree().get_first_node_in_group("Players") # keeps returning null, so I added it to the setget
var stats: Dictionary
var current_health: int
var overcapped_health: int
var base_stats

func get_stats():
	player = get_tree().get_nodes_in_group("Players")[0]
	base_stats = player._player_stats
	stats = player._player_stats.stats
	current_health = player._player_stats.health
	overcapped_health = player._player_stats.overcapped_health
	return stats

func set_stats():
	player = get_tree().get_nodes_in_group("Players")[0]
	player._player_stats = base_stats
	player._player_stats.stats = stats
	player._player_stats.health = current_health
	player._player_stats.overcapped_health = overcapped_health
