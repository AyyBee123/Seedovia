extends "res://Scripts/Passives/Classes/passive_tally.gd"

@onready var resource_preloader := $ResourcePreloader

@export var damage_multiplier: float = 3
@export var explosion_size_multiplier: float = 1.5

func add_tally(weapon = null):
	super.add_tally()
	if tally_count % 3 == 0 and tally_count != 0:
		explode()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.object = player
	explosion.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
	explosion.size = player._player_stats.get_stat("Weapon_Blast_Radius") * explosion_size_multiplier
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = player.global_position
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.GOLD
