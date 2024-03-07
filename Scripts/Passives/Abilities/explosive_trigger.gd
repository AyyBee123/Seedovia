extends "res://Scripts/Passives/Classes/passive_tally.gd"

@onready var resource_preloader := $ResourcePreloader

func add_tally():
	super.add_tally()
	if (tally_count % 3 == 0 and tally_count != 0):
		explode()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = player.global_position
	explosion.object = player
	explosion.damage = player._player_stats.get_stat("Weapon_Damage")
	explosion.damage_multiplier = 3
	explosion.size = player._player_stats.get_stat("Weapon_Blast_Radius")
	explosion.get_node("AnimatedSprite2D").self_modulate = Color(1,1,0)
