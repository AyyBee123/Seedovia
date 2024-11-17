extends Node

var add_talismans_passive = preload("res://Scenes/Characters/Passives/Add Talismans.tscn")

var starting_character: character_class
var _is_starting := false

func set_inventory():
	add_items(starting_character.starting_inventory, PlayerInventory.inventory)
	#add_items(starting_character.starting_talismans, PlayerInventory.talismans)
	#for talisman in starting_character.starting_talismans:
		#for passive in talisman.special_properties:
			#PlayerPassives.item_passives.append(passive)
	add_items(starting_character.starting_seeds, PlayerInventory.seeds)

func add_items(category, player_category):
	var index = 0
	for item in category:
		if item != null:
			player_category[index] = item
		index += 1

func add_passives():
	PlayerPassives.starting_passives = starting_character.starting_passives
	PlayerPassives.starting_passives.append(add_talismans_passive)
