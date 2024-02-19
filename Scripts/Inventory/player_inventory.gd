extends Node

const item_instance = preload("res://Scripts/Items/item.gd")
const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")

var picked_up_item = null

const NUM_INVENTORY_SLOTS = 12


var inventory = {}
var equipment = {}#{1: "Basic Helmet", 3: "Basic Body Armour"}

func add_item(item):
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i): # checks for space in inventory
			inventory[i] = item.item_name
			picked_up_item = item
			return
		else: # if inventory is full
			pass

func add_item_to_empty_slot(item: item_instance, slot: slot_class):
	if slot.slot_type == slot_class.slot_types.INVENTORY:
		inventory[slot.slot_index] = item.item.get_item_name()
	else:
		equipment[slot.slot_index] = item.item.get_item_name()
	
func remove_item(slot: slot_class):
	if slot.slot_type == slot_class.slot_types.INVENTORY:
		inventory.erase(slot.slot_index)
	else:
		equipment.erase(slot.slot_index)
	
