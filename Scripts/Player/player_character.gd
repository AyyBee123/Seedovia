extends Node

var starting_character: character_class
# the sprite is stored here instead of in the character class resource because the sprite is loading later, 
# causing a nil/null error
var sprite
var hand_sprite

func set_inventory():
	sprite = starting_character.sprite
	hand_sprite = starting_character.hand_sprite
	add_items(starting_character.starting_inventory, PlayerInventory.inventory)
	add_items(starting_character.starting_talismans, PlayerInventory.talismans)
	add_items(starting_character.starting_seeds, PlayerInventory.seeds)

func add_items(category, player_category):
	var index = 0
	for item in category:
		player_category[index] = item
		index += 1

func add_passives():
	pass
