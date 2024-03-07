extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader := $ResourcePreloader

func _ready():
	chance = 0.25
	player.weapon_fired.connect(chance_to_trigger)
	super._ready()

func trigger():
	var banana = resource_preloader.get_resource("Banana").instantiate()
	get_tree().current_scene.add_child(banana)
	banana.global_position = player.global_position
	banana.object = player
	banana.damage = player._player_stats.get_stat("Weapon_Damage")
	banana.damage_multiplier = 1.5
	banana.speed = player._player_stats.get_stat("Weapon_Speed")
	banana.speed_multiplier = 1
	banana.explosion_size = player._player_stats.get_stat("Weapon_Blast_Radius")
