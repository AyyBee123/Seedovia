extends Node

@onready var player = get_tree().get_first_node_in_group("Players") # keeps returning null, so I added it to the setget
var passives: Array
var item_passives: Array
var starting_passives: Array[passive_class]
var passive_list: Array # keeps a list of resources to display in the stat sheet

func get_passives(): # get the passives and save them into the current run save file
	player = get_tree().get_nodes_in_group("Players")[0]
	passives.clear()
	for passive in player.get_node("Passives").get_children():
		var packed_scene = PackedScene.new()
		packed_scene.pack(passive)
		passives.append(packed_scene)
	return passives

func get_item_passives(): # get the item passives and save them into the current run save file
	player = get_tree().get_nodes_in_group("Players")[0]
	item_passives.clear()
	for passive in player.get_node("Item Passives").get_children():
		var packed_scene = PackedScene.new()
		packed_scene.pack(passive)
		item_passives.append(packed_scene)
	return item_passives

func set_passives(): # set the passives and load them from the current run save file into the player node
	player = get_tree().get_nodes_in_group("Players")[0]
	for passive in passives:
		player.get_node("Passives").add_child(passive.instantiate())

func set_item_passives(): # set the item passives and load them from the current run save file into the player node
	player = get_tree().get_nodes_in_group("Players")[0]
	for passive in item_passives:
		player.get_node("Item Passives").add_child(passive.instantiate())

func add_starting_passives(): # add the starting character's passive(s) into the player node
	player = get_tree().get_nodes_in_group("Players")[0]
	for passive in starting_passives:
		player.get_node("Passives").add_child(passive.passive_ability.instantiate())
