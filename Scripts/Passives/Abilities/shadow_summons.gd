extends Node

const SHADOW = preload("res://Scenes/Passives/Effects/Shadow.tscn")

var player

func _ready():
	player = get_parent().get_parent()
	
	var dir = [-1, 1]
	
	await get_tree().physics_frame
	
	if player == Targets.get_player():
		for i in dir:
			var shadow = SHADOW.instantiate()
			shadow.add_child(player.get_node("Passives").duplicate())
			shadow.add_child(player.get_node("Item Passives").duplicate())
			get_tree().current_scene.add_child(shadow)
			shadow.global_position = player.global_position + Vector2(100 * i, 0)
