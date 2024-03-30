extends Control

const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")
@onready var player = $".."
@onready var inventory_slots = $"Inventory Screen/Inventory Slots".get_children()
@onready var equip_slots = $"Inventory Screen/Equipment Slots".get_children()
@onready var seed_slots = $"Inventory Screen/Seed Slots".get_children()
var holding_item = null # the item that is currently being held by the cursor in the inventory
var drop_delay = Timer.new()

func _ready():
	add_child(drop_delay)
	drop_delay.one_shot = true
	drop_delay.wait_time = 0.1
	visible = false # make inventory not visible on starting the game
	# initialize all the inventory slots and their categories
	for i in range(inventory_slots.size()):
		inventory_slots[i].gui_input.connect(slot_gui_input.bind(inventory_slots[i]))
		inventory_slots[i].slot_index = i
		inventory_slots[i].slot_type = slot_class.slot_types.INVENTORY
		
	# remove the empty space nodes (TextureRects) from the equipment grid container
	var temp_equip_slots = []
	for slot in equip_slots:
		if slot is Panel:
			temp_equip_slots.append(slot)
			continue
	equip_slots = temp_equip_slots
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
	equip_slots[3].slot_type = slot_class.slot_types.LEGS
	
	inititialize_inventory()
	inititialize_equipment()
	inititialize_seeds()

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		# toggle inventory UI to open/close
		visible = !visible
	if holding_item == null:
		if drop_delay.is_stopped():
			player.has_holding_item = false
	else:
		player.has_holding_item = true
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
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			if holding_item == null:
				if slot.item:
					right_click_use_item(slot)

func _input(event):
	inititialize_inventory()
	inititialize_equipment()
	inititialize_seeds()
	if holding_item:
		holding_item.global_position = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			#drop item if mouse is outside inventory and has a holding item after left mouse click
			if not player.mouse_in_inventory && holding_item != null:
				PlayerInventory.drop_item(holding_item.item, player)
				holding_item.queue_free()
				holding_item = null
				drop_delay.start() # delay to prevent shooting while dropping the item to the ground

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
	elif slot.slot_type == slot_class.slot_types.LEGS:
		return holding_item_category == "LEGS"
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

func right_click_use_item(slot: slot_class):
	if slot.slot_type == slot_class.slot_types.INVENTORY:
		match slot.item.item.category:
			"CONSUMABLE":
				slot.item.item.on_use(player)
				PlayerInventory.remove_item(slot)
				slot.item.call_deferred("free")
			"HEAD":
				if !equip_slots[0].item:
					right_click_slot_item(slot, equip_slots[0])
			"ARMS":
				if !equip_slots[1].item:
					right_click_slot_item(slot, equip_slots[1])
			"BODY":
				if !equip_slots[2].item:
					right_click_slot_item(slot, equip_slots[2])
			"LEGS":
				if !equip_slots[3].item:
					right_click_slot_item(slot, equip_slots[3])
			#"SEED":
				#pass

func right_click_slot_item(selected_slot: slot_class, desired_slot: slot_class):
	var current_item = selected_slot.item
	PlayerInventory.remove_item(selected_slot)
	selected_slot.pick_from_slot()
	PlayerInventory.add_item_to_empty_slot(current_item, desired_slot)
	desired_slot.get_node("Silhouette").visible = false
	desired_slot.put_into_slot(current_item)

func get_number_of_slots():
	return inventory_slots.size()
