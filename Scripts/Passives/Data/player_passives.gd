extends Node

@onready var player = get_tree().get_first_node_in_group("Players") # keeps returning null, so I added it to the setget
var passives: Array
var item_passives: Array

func get_passives():
	player = get_tree().get_nodes_in_group("Players")[0]
	passives.clear()
	for passive in player.get_node("Passives").get_children():
		var packed_scene = PackedScene.new()
		packed_scene.pack(passive)
		passives.append(packed_scene)
	return passives

func get_item_passives():
	player = get_tree().get_nodes_in_group("Players")[0]
	item_passives.clear()
	for passive in player.get_node("Item Passives").get_children():
		var packed_scene = PackedScene.new()
		packed_scene.pack(passive)
		item_passives.append(packed_scene)
	return item_passives

func set_passives():
	player = get_tree().get_nodes_in_group("Players")[0]
	for passive in passives:
		player.get_node("Passives").add_child(passive.instantiate())

func set_item_passives():
	player = get_tree().get_nodes_in_group("Players")[0]
	for passive in item_passives:
		player.get_node("Item Passives").add_child(passive.instantiate())
