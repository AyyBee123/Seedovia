extends Node

var add_talismans_passive = preload("res://Scenes/Characters/Passives/Add Talismans.tscn")

var starting_character: character_class
var character_name: String
# the sprite is stored here instead of in the character class resource because the sprite is loading later, 
# causing a nil/null error
var sprite
var hand_sprite
var move_animation: Array[Texture]

func set_inventory():
	sprite = starting_character.sprite
	hand_sprite = starting_character.hand_sprite
	move_animation = starting_character.move_animation
	character_name = starting_character.character_name
	add_items(starting_character.starting_inventory, PlayerInventory.inventory)
	add_items(starting_character.starting_talismans, PlayerInventory.talismans)
	for talisman in starting_character.starting_talismans:
		for passive in talisman.special_properties:
			PlayerPassives.item_passives.append(passive)
	add_items(starting_character.starting_seeds, PlayerInventory.seeds)

func add_items(category, player_category):
	var index = 0
	for item in category:
		if item != null:
			player_category[index] = item
		index += 1

func add_passives():
	PlayerPassives.starting_passives = starting_character.starting_passives
