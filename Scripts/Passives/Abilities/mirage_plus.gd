extends Node

const MIRAGE_CLONE = preload("res://Scenes/Passives/Effects/Mirage Clone.tscn")

const NUMBER_OF_CLONES = 3

var player

func _ready():
	player = get_parent().get_parent()
	
	var spread = TAU / NUMBER_OF_CLONES
	
	await get_tree().physics_frame
	
	if player == Targets.get_player():
		for i in NUMBER_OF_CLONES:
			var clone = MIRAGE_CLONE.instantiate()
			clone.add_child(player.get_node("Passives").duplicate())
			clone.add_child(player.get_node("Item Passives").duplicate())
			clone.offset = Vector2(0, -100).rotated(spread * i)
			get_tree().current_scene.add_child(clone)
			clone.global_position = player.global_position + clone.offset
