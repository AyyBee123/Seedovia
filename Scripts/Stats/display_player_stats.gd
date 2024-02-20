extends Control

@onready var player = $"../Player"
@onready var stats = $"Stats UI".get_children()

func _ready():
	initialize_stats()
	
func initialize_stats():
	stats[0].text = stats[0].name + ": " + str(player.player_stats.health)
	stats[1].text = stats[1].name + ": " + str(player.player_stats.speed)
	stats[2].text = stats[2].name + ": " + str(player.player_stats.dash_rate)
	stats[3].text = stats[3].name + ": " + str(player.player_stats.dash_distance)
	stats[4].text = stats[4].name + ": " + str(player.player_stats.dash_invulnerability)
	stats[5].text = stats[5].name + ": " + str(player.player_stats.fire_rate)
		
func update_stats():
	for i in range(stats):
		pass
