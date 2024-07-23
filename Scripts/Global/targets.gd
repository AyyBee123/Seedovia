extends Node

var player
var enemies
var items
var doors
var camera

func get_entities():
	player = get_tree().get_first_node_in_group("Players")
	enemies = get_tree().get_nodes_in_group("Enemy")
	items = get_tree().get_nodes_in_group("Item")
	doors = get_tree().get_nodes_in_group("Door")
	camera = get_tree().get_first_node_in_group("Main Camera")

func get_player():
	return get_tree().get_first_node_in_group("Players")

func get_enemies():
	return get_tree().get_nodes_in_group("Enemy")

func get_items():
	items = get_tree().get_nodes_in_group("Item")
