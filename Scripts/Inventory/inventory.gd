extends Control

const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")
@onready var drop_button = $"NinePatchRect/Drop Button"
@onready var player = $".."
@onready var inventory_slots = $"NinePatchRect/Inventory Slots".get_children()
@onready var equip_slots = $"NinePatchRect/Equipment Slots".get_children()
@onready var seed_slots = $"NinePatchRect/Seed Slots".get_children()
var holding_item = null # the item that is currently being held by the cursor in the inventory
#var mouse_in_inventory = self.get_global_rect().has_point(self.get_global_mouse_position()) and is_visible_in_tree()

func _ready():
	visible = false # make inventory not visible on starting the game
	# initialize all the inventory slots and their categories
	for i in range(inventory_slots.size()):
		inventory_slots[i].gui_input.connect(slot_gui_input.bind(inventory_slots[i]))
		inventory_slots[i].slot_index = i
		inventory_slots[i].slot_type = slot_class.slot_types.INVENTORY
		
	# remove the empty space nodes (TextureRects) from the equipment grid container
	for i in range(seed_slots.size()):
		if not equip_slots[i] is Panel:
			equip_slots.remove_at(i)
			continue
	# initialize all the seed slots and their categories
	for i in range(seed_slots.size()):
		seed_slots[i].gui_input.connect(slot_gui_input.bind(seed_slots[i]))
		seed_slots[i].slot_index = i
		seed_slots[i].slot_type = slot_class.slot_types.SEED
		
	# initialize all the equipment slots
	for i in range(equip_slots.size()):
		equip_slots[i].gui_input.connect(slot_gui_input.bind(equip_slots[i]))
		equip_slots[i].slot_index = i
	# initialize all the equipment slots' categories
	equip_slots[0].slot_type = slot_class.slot_types.HEAD
	equip_slots[1].slot_type = slot_class.slot_types.ARMS
	equip_slots[2].slot_type = slot_class.slot_types.BODY
	equip_slots[3].slot_type = slot_class.slot_types.SHOULDERS
	equip_slots[4].slot_type = slot_class.slot_types.LEGS
	equip_slots[5].slot_type = slot_class.slot_types.WAIST
	equip_slots[6].slot_type = slot_class.slot_types.FEET
	
	inititialize_inventory()
	inititialize_equipment()
	inititialize_seeds()
	
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		# toggle inventory UI to open/close
		visible = !visible
	# return item to inventory when exiting the inventory UI while holding an item (or drop when inventory is full)
	if not visible && holding_item != null:
		PlayerInventory.add_item(holding_item.item, player, self)
		holding_item.queue_free()
		holding_item = null
		
func slot_gui_input(event: InputEvent, slot: slot_class):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if holding_item != null:
				#if not mouse_in_inventory:
					#PlayerInventory.drop_item(holding_item, player)
				if !slot.item: # place holding item into a slot
					left_click_place_item(slot)
				else: # swap holding item with item in slot
					left_click_swap_item(event, slot)
			elif slot.item: # left clicking an item while not currently holding an item
				left_click_select_item(slot)
				
func _input(event):
	inititialize_inventory()
	inititialize_equipment()
	inititialize_seeds()
	if holding_item:
		holding_item.global_position = get_global_mouse_position()
		
func inititialize_inventory():
	for i in range(inventory_slots.size()):
		if PlayerInventory.inventory.has(i):
			inventory_slots[i].initialize_item(PlayerInventory.inventory[i])
			
func inititialize_equipment():
	for i in range(equip_slots.size()):
		if PlayerInventory.equipment.has(i):
			equip_slots[i].get_node("Silhouette").visible = false
			equip_slots[i].initialize_item(PlayerInventory.equipment[i])
			
func inititialize_seeds():
	for i in range(seed_slots.size()):
		if PlayerInventory.seeds.has(i):
			seed_slots[i].get_node("Silhouette").visible = false
			seed_slots[i].initialize_item(PlayerInventory.seeds[i])
			
func able_to_put_into_slot(slot: slot_class) -> bool:
	if holding_item == null:
		return true
	# set the category as INVENTORY if there is no category property in the item resource
	# consumable items don't have a category property, so their category is always INVENTORY
	var holding_item_category = "INVENTORY" if not "category" in holding_item.item else holding_item.item.category
	# check the slot type of the slot
	if slot.slot_type == slot_class.slot_types.HEAD:
		return holding_item_category == "HEAD"
	elif slot.slot_type == slot_class.slot_types.ARMS:
		return holding_item_category == "ARMS"
	elif slot.slot_type == slot_class.slot_types.BODY:
		return holding_item_category == "BODY"
	elif slot.slot_type == slot_class.slot_types.SHOULDERS:
		return holding_item_category == "SHOULDERS"
	elif slot.slot_type == slot_class.slot_types.LEGS:
		return holding_item_category == "LEGS"
	elif slot.slot_type == slot_class.slot_types.WAIST:
		return holding_item_category == "WAIST"
	elif slot.slot_type == slot_class.slot_types.FEET:
		return holding_item_category == "FEET"
	elif slot.slot_type == slot_class.slot_types.SEED:
		return holding_item_category == "SEED"
	else: # if the category is INVENTORY (since inventory can fit anything, it will return true)
		return true
			
func left_click_place_item(slot: slot_class): # place holding item into a slot
	if able_to_put_into_slot(slot):
		PlayerInventory.add_item_to_empty_slot(holding_item, slot)
		slot.put_into_slot(holding_item)
		if slot.slot_type != slot_class.slot_types.INVENTORY: # "replace" silhouette sprite with item sprite
			slot.get_node("Silhouette").visible = false
		holding_item = null
	
func left_click_swap_item(event: InputEvent, slot: slot_class): # swap holding item with item in slot
	if able_to_put_into_slot(slot):
		PlayerInventory.remove_item(slot)
		PlayerInventory.add_item_to_empty_slot(holding_item, slot)
		var temp_item = slot.item
		slot.pick_from_slot()
		temp_item.global_position = event.global_position
		slot.put_into_slot(holding_item)
		holding_item = temp_item
	
func left_click_select_item(slot: slot_class): # left clicking an item while not currently holding an item
	PlayerInventory.remove_item(slot)
	holding_item = slot.item
	slot.pick_from_slot()
	if slot.slot_type != slot_class.slot_types.INVENTORY: # "replace" item sprite with silhouette sprite
		slot.get_node("Silhouette").visible = true
	holding_item.global_position = get_global_mouse_position()
	
func _on_drop_button_pressed():
	if holding_item != null:
		PlayerInventory.drop_item(holding_item.item, player)
		holding_item.queue_free()
		holding_item = null
	
func get_number_of_slots():
	return inventory_slots.size()
