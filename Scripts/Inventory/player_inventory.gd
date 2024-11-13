extends Node

const item_instance = preload("res://Scripts/Items/item.gd")
const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")

var picked_up_item = null

const NUM_INVENTORY_SLOTS = 12
const NUM_TALISMAN_SLOTS = 4
const NUM_SEED_SLOTS = 3

var inventory = {}
var talismans = {}
var seeds = {}

func check_for_items():
	LevelList.items_on_ground.clear()
	var i = 0
	# check all direct children of the scene (i.e. all nodes on the ground)
	for item in get_tree().current_scene.get_children():
		print(item.name)
		# get the item and its current position, stored as a dictionary
		if item.is_in_group("Item"):
			LevelList.items_on_ground[i] = {
				"item": item.item, 
				"position": item.global_position
			}
			i += 1

func add_item(item, player, inv):
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i): # checks for space in inventory (if the slot is empty)
			picked_up_item = item
			inventory[i] = item
			await get_tree().create_timer(0.5).timeout
			check_for_items()
			Global.save_data()
			Global.save_room()
			return
	# if inventory is full
	drop_item(item, player)
	Global.save_data()
	Global.save_room()

func drop_item(item, player):
	var current_item = load("res://Scenes/Items/item.tscn").instantiate()
	# set the dropped item's resource values from the holding item or dropped item if inventory is full
	current_item.set_item(item)
	get_tree().current_scene.add_child(current_item)
	current_item.global_position = player.global_position
	await get_tree().create_timer(0.5).timeout
	check_for_items()
	Global.save_data()
	Global.save_room()

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
