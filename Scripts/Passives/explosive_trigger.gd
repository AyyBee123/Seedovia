extends "res://Scripts/Passives/passive_behaviour.gd"

@onready var resource_preloader := $ResourcePreloader

func add_tally():
	super.add_tally()
	if (tally_count % 3 == 0 and tally_count != 0):
		explode()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = player.global_position
	explosion.player = player
	explosion.damage = player._player_stats.get_stat("Weapon_Damage")
	explosion.damage_multiplier = 3
