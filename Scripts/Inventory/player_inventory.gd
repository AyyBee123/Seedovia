extends Node

const item_instance = preload("res://Scripts/Items/item.gd")
const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")

var picked_up_item = null

var NUM_INVENTORY_SLOTS = 12
var NUM_TALISMAN_SLOTS = 4
var NUM_SEED_SLOTS = 3

var inventory = {}
var talismans = {}
var seeds = {}

func add_item(item, player, inv):
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i): # checks for space in inventory (if the slot is empty)
			picked_up_item = item
			inventory[i] = item
			await get_tree().process_frame
			ItemCheck.check_for_items()
			ItemCheck.check_for_shop_items()
			Global.save_run_data()
			Global.save_run_room()
			return
	# if inventory is full
	drop_item(item, player)
	Global.save_run_data()
	Global.save_run_room()

func drop_item(item, player):
	var current_item = load("res://Scenes/Items/Item.tscn").instantiate()
	# set the dropped item's resource values from the holding item or dropped item if inventory is full
	current_item.set_item(item)
	get_tree().current_scene.add_child(current_item)
	current_item.global_position = player.global_position
	await get_tree().process_frame
	ItemCheck.check_for_items()
	Global.save_run_data()
	Global.save_run_room()

func equip_item(item, player, inv):
	var capacity: int
	if item.category == "SEED":
		for i in range(NUM_SEED_SLOTS):
			if not seeds.has(i): # checks for space in inventory (if the slot is empty)
				picked_up_item = item
				seeds[i] = item
	elif item.category == "TALISMAN":
		for i in range(NUM_TALISMAN_SLOTS):
			if not talismans.has(i): # checks for space in inventory (if the slot is empty)
				picked_up_item = item
				talismans[i] = item
	else:
		add_item(item, player, inv)
		return
	await get_tree().process_frame
	ItemCheck.check_for_items()
	ItemCheck.check_for_shop_items()
	Global.save_run_data()
	Global.save_run_room()

func add_item_to_empty_slot(item: item_instance, slot: slot_class):
	if slot.slot_type == slot_class.slot_types.INVENTORY:
		inventory[slot.slot_index] = item.item
	elif slot.slot_type == slot_class.slot_types.SEED:
		seeds[slot.slot_index] = item.item
	else: # equipment
		talismans[slot.slot_index] = item.item

func remove_item(slot: slot_class):
	if slot.slot_type == slot_class.slot_types.INVENTORY:
		inventory.erase(slot.slot_index)
	elif slot.slot_type == slot_class.slot_types.SEED:
		seeds.erase(slot.slot_index)
	else: # talisman
		talismans.erase(slot.slot_index)

func get_empty_slot_index():
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i): # checks for space in inventory
			return i
	# if inventory is full
	return null
