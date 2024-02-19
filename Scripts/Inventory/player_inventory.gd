extends Node

const item_instance = preload("res://Scripts/Items/item.gd")
const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")
const inventory_ui = preload("res://Scripts/Inventory/inventory.gd")

var picked_up_item = null

const NUM_INVENTORY_SLOTS = 12


var inventory = {}
var equipment = {}#{1: "Basic Helmet", 3: "Basic Body Armour"}

func add_item(item, player, inv):
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i): # checks for space in inventory
			picked_up_item = item
			inventory[i] = item
			return
	# if inventory is full
	drop_item(item, player)
	
func drop_item(item, player):
	var current_item = load("res://Scenes/Items/item.tscn").instantiate()
	# set the dropped item's resource values from the holding item or dropped item if inventory is full
	current_item.set_item(item)
	get_tree().current_scene.add_child(current_item)
	current_item.global_position = player.global_position

func add_item_to_empty_slot(item: item_instance, slot: slot_class):
	if slot.slot_type == slot_class.slot_types.INVENTORY:
		inventory[slot.slot_index] = item.item
	else:
		equipment[slot.slot_index] = item.item
	
func remove_item(slot: slot_class):
	if slot.slot_type == slot_class.slot_types.INVENTORY:
		inventory.erase(slot.slot_index)
	else:
		equipment.erase(slot.slot_index)
