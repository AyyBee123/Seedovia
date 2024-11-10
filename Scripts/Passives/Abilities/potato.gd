extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader = $ResourcePreloader

func _ready():
	chance = 1
	super._ready()
	player.dashed.connect(chance_to_trigger)

func trigger(weapon = null):
	var potato = resource_preloader.get_resource("Potato Mine").instantiate()
	potato.damage = player._player_stats.get_stat("Weapon_Damage")
	potato.blast_radius_multiplier = player._player_stats.get_stat("Weapon_Blast_Radius")
	potato.player = player
	get_tree().current_scene.add_child(potato)
	potato.global_position = player.global_position
