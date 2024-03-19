extends Node

@onready var player = get_tree().get_nodes_in_group("Players")[0] # keeps returning null, so I added it to the setget
var passives: Array
var packed_scene = PackedScene.new()

func get_passives():
	player = get_tree().get_nodes_in_group("Players")[0]
	passives.clear()
	for passive in player.get_node("Passives").get_children():
		packed_scene.pack(passive)
		passives.append(packed_scene)
	return passives

func set_passives():
	player = get_tree().get_nodes_in_group("Players")[0]
	for passive in passives:
		player.get_node("Passives").add_child(passive.instantiate())
