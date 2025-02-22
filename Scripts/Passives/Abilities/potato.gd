extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader = $ResourcePreloader

func _ready():
	chance = 1
	super._ready()
	player.dashed.connect(chance_to_trigger)

func trigger(weapon = null):
	var potato = resource_preloader.get_resource("Potato Mine").instantiate()
	potato.DAMAGE = player.DAMAGE
	potato.BLAST_RADIUS = player.BLAST_RADIUS
	potato.player = player
	get_tree().current_scene.add_child(potato)
	potato.global_position = player.global_position
