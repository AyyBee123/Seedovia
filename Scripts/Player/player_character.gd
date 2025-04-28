extends Node

var add_talismans_passive = preload("res://Resources/Characters/Passives/add_talisman_passives.tres")

var starting_character: character_class
var _is_starting := false
var coins: int

func set_inventory():
	# NOTE: Talismans are set up in the add_passives function using the add_talisman_passive scene
	add_items(starting_character.starting_inventory, PlayerInventory.inventory)
	add_items(starting_character.starting_seeds, PlayerInventory.seeds)

func add_items(category, player_category):
	var index = 0
	for item in category:
		if item != null:
			player_category[index] = item
		index += 1

func add_passives():
	PlayerPassives.starting_passives = starting_character.starting_passives
	PlayerPassives.passive_list = starting_character.starting_passives
	PlayerPassives.starting_passives.append(add_talismans_passive)
