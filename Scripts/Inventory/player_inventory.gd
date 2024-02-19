extends Node

const item_instance = preload("res://Scripts/Items/item.gd")
const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")
const inventory_ui = preload("res://Scripts/Inventory/inventory.gd")

var picked_up_item = null

const NUM_INVENTORY_SLOTS = 12


var inventory = {0:load("res://Resources/Items/Consumables/apple.tres"),
1:load("res://Resources/Items/Consumables/apple.tres"),
2:load("res://Resources/Items/Consumables/apple.tres"),
3:load("res://Resources/Items/Consumables/apple.tres"),
4:load("res://Resources/Items/Consumables/apple.tres"),
5:load("res://Resources/Items/Consumables/apple.tres"),
6:load("res://Resources/Items/Consumables/apple.tres"),
7:load("res://Resources/Items/Consumables/apple.tres"),
8:load("res://Resources/Items/Consumables/apple.tres"),
9:load("res://Resources/Items/Consumables/apple.tres"),
10:load("res://Resources/Items/Consumables/apple.tres"),
11:load("res://Resources/Items/Consumables/apple.tres"),
12:load("res://Resources/Items/Consumables/apple.tres"),}
var equipment = {}#{1: "Basic Helmet", 3: "Basic Body Armour"}

func add_item(item, player, inv):
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i): # checks for space in inventory
			picked_up_item = item
			inventory[i] = item
			return
	# if inventory is full
	inv.drop_item(item, player)
	

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
