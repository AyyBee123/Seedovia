extends Node

@onready var resource_preloader = $ResourcePreloader

var player

func _ready():
	player = Targets.get_player()
	# add the sunflower light effect to the player scene
	if not player.find_child("Sunflower Light"):
		var sunflower_light = resource_preloader.get_resource("Sunflower Light").instantiate()
		sunflower_light.damage = player._player_stats.get_stat("Weapon_Damage")
		sunflower_light.size = player._player_stats.get_stat("Weapon_Size")
		player.add_child(sunflower_light)
