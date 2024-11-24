extends Node

var player
var weapons
var enemies
var items
var pickups
var doors
var camera
var scene
var coins
var shop_items

func get_entities():
	player = get_tree().get_first_node_in_group("Players")
	weapons = get_tree().get_nodes_in_group("Weapon")
	enemies = get_tree().get_nodes_in_group("Enemy")
	items = get_tree().get_nodes_in_group("Item")
	pickups = get_tree().get_nodes_in_group("Pickup Item")
	doors = get_tree().get_nodes_in_group("Door")
	camera = get_tree().get_first_node_in_group("Main Camera")
	scene = get_tree().current_scene
	coins = get_tree().get_nodes_in_group("Coin")
	shop_items = get_tree().get_nodes_in_group("Shop Item")

func get_player():
	return get_tree().get_first_node_in_group("Players")

func get_weapons():
	return get_tree().get_nodes_in_group("Weapon")

func get_enemies():
	return get_tree().get_nodes_in_group("Enemy")

func get_enemy_hitboxes():
	return get_tree().get_nodes_in_group("Enemies")

func get_all_items():
	var new_array = get_tree().get_nodes_in_group("Item")
	new_array.append_array(get_tree().get_nodes_in_group("Pickup Item"))
	return new_array

func get_items():
	return get_tree().get_nodes_in_group("Item")

func get_pickup_items():
	return get_tree().get_nodes_in_group("Pickup Item")

func get_scene():
	return get_tree().current_scene

func get_camera():
	return get_tree().get_first_node_in_group("Main Camera")

func get_doors():
	return get_tree().get_nodes_in_group("Door")

func get_coins():
	return get_tree().get_nodes_in_group("Coin")

func get_shop_items():
	return get_tree().get_nodes_in_group("Shop Item")
