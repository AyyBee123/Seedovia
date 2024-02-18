extends Node

const item_class = preload("res://Scripts/Items/item.gd")
const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")

const NUM_INVENTORY_SLOTS = 12

var inventory = {}

func add_item(item_name):
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i):
			inventory[i] = item_name
			return

func add_item_to_empty_slot(item: item_class, slot: slot_class):
	inventory[slot.slot_index] = item.i_stats.item_name
	
func remove_item(slot: slot_class):
	inventory.erase(slot.slot_index)
	
