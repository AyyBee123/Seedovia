extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader := $ResourcePreloader

@export var damage_multiplier: float = 1.5
@export var speed_multiplier: float = 1

func _ready():
	chance = 0.25
	player.weapon_fired.connect(chance_to_trigger)
	super._ready()

func trigger(weapon = null):
	var banana = resource_preloader.get_resource("Banana").instantiate()
	get_tree().current_scene.add_child(banana)
	banana.global_position = player.global_position
	banana.object = player
	banana.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
	banana.speed = player._player_stats.get_stat("Weapon_Speed") * speed_multiplier
	banana.explosion_size = player._player_stats.get_stat("Weapon_Blast_Radius")
