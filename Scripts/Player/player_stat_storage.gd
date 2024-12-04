extends Node

@onready var player = Targets.get_player()
var stats: Dictionary
var current_health: int
var overcapped_health: int
var leaf_hearts: int

func get_stats():
	player = Targets.get_player()
	stats = player._player_stats.stats
	current_health = player._player_stats.health
	overcapped_health = player._player_stats.overcapped_health
	leaf_hearts = player._player_stats.leaf_hearts
	return stats

func set_stats():
	player = Targets.get_player()
	player._player_stats.stats = stats
	player._player_stats.health = current_health
	player._player_stats.overcapped_health = overcapped_health
	player._player_stats.leaf_hearts = leaf_hearts
