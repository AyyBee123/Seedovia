extends Control

@onready var player = $"../Player"
@onready var stats = $"Layout/Stats UI".get_children()
@onready var max_health = $"Layout/PanelContainer/Max Health UI"
@onready var current_health = $"Layout/PanelContainer/Current Health UI"
var empty_heart = preload("res://Scenes/UI/empty_heart.tscn")
var filled_heart = preload("res://Scenes/UI/filled_heart.tscn")

func _ready():
	initialize_stats()
	
func initialize_stats():
	set_health()
	stats[0].text = stats[0].name + ": " + str(player._player_stats.speed)
	stats[1].text = stats[1].name + ": " + str(player._player_stats.dash_rate)
	stats[2].text = stats[2].name + ": " + str(player._player_stats.dash_distance)
	stats[3].text = stats[3].name + ": " + str(player._player_stats.dash_invulnerability)
	stats[4].text = stats[4].name + ": " + str(player._player_stats.fire_rate)
	
func set_health():
	# remove all hearts in the health ui
	for i in max_health.get_children(): # remove empty heart containers
		max_health.remove_child(i)
		i.queue_free()
	for i in current_health.get_children(): # remove filled heart containers
		current_health.remove_child(i)
		i.queue_free()
	# add hearts in the hearts ui
	for i in range(player._player_stats.max_health): # add empty heart containers
		var heart_instance = empty_heart.instantiate()
		max_health.add_child(heart_instance)
	for i in range(player._player_stats.health): # add filled heart containers
		var heart_instance = filled_heart.instantiate()
		current_health.add_child(heart_instance)
