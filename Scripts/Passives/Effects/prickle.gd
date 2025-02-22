extends Node

@onready var resource_preloader = $ResourcePreloader

var DAMAGE
var damage_multiplier: float = 0.5
var size: float
var size_multiplier: float = 0.5
var weapon
var tick_rate := 0.2

func _ready():
	var weapon = get_parent().get_parent()
	var player = Targets.get_player()
	var seeds = Targets.get_weapons()
	for seed in seeds:
		if seed == weapon: # if the currently looked at weapon is itself, do nothing
			continue
		var prickle_stem = resource_preloader.get_resource("Prickle Stem").instantiate()
		prickle_stem.DAMAGE = weapon.DAMAGE
		prickle_stem.size = weapon.SIZE
		prickle_stem.target = seed
		prickle_stem.source = weapon
		prickle_stem.tick_rate = tick_rate
		get_tree().current_scene.add_child.call_deferred(prickle_stem)
		prickle_stem.global_position = weapon.global_position
