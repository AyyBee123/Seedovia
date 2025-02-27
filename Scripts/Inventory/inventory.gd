extends Control

const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")
@onready var player = $".."
@onready var inventory_slots = $"Inventory Screen/Inventory Slots".get_children()
@onready var talisman_slots = $"Inventory Screen/Talisman Slots".get_children()
@onready var seed_slots = $"Inventory Screen/Seed Slots".get_children()
@onready var selected_slot = $"Selected Slot"

var holding_item = null # the item that is currently being held by the cursor in the inventory
var previous_holding_item
var holding_item_player_pos
var drop_delay = Timer.new()
var _isMandK := true
# set the default selected slot (for controller inventory navigation)
var selected_slot_index: int
var all_slots: Array
# get the current index the controller navigation box is in to add a popup there (if there is an item in that slot)
var current_index_popup: int

func _ready():
	add_child.call_deferred(drop_delay)
	drop_delay.one_shot = true
	drop_delay.wait_time = 0.1
	visible = false # make inventory not visible on starting the game
	# connect each inventory slot with the slot_gui_input function, binding the slot as the unique identifier
	# gui_input is a built-in signal that is emitted when an input is pressed in the gui
	# initialize all the seed slots and their categories
	for i in range(seed_slots.size()):
		seed_slots[i].gui_input.connect(slot_gui_input.bind(seed_slots[i]))
		seed_slots[i].slot_index = i
		seed_slots[i].slot_type = slot_class.slot_types.SEED
		all_slots.append(seed_slots[i])
	# initialize all the talisman slots
	for i in range(talisman_slots.size()):
		talisman_slots[i].gui_input.connect(slot_gui_input.bind(talisman_slots[i]))
		talisman_slots[i].slot_index = i
		talisman_slots[i].slot_type = slot_class.slot_types.TALISMAN
		all_slots.append(talisman_slots[i])
	# initialize all the inventory slots and their categories
	for i in range(inventory_slots.size()):
		inventory_slots[i].gui_input.connect(slot_gui_input.bind(inventory_slots[i]))
		inventory_slots[i].slot_index = i
		inventory_slots[i].slot_type = slot_class.slot_types.INVENTORY
		all_slots.append(inventory_slots[i])
	# set the initial position and value of the (yellow) selected slot for controller as the first inventory slot
	selected_slot.global_position = all_slots[7].global_position
	selected_slot_index = 7
	current_index_popup = selected_slot_index
	
	initialize_inventory()
	initialize_talisman()
	initialize_seeds()

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
	if not visible and holding_item != null:
		PlayerInventory.add_item(holding_item.item, player, self)
		holding_item.queue_free()
		holding_item = null
	if visible:
		if not _isMandK:
			selected_slot.visible = true
		if _isMandK:
			selected_slot.visible = false
	if all_slots[selected_slot_index].item and all_slots[selected_slot_index].popup == null and not _isMandK:
		all_slots[selected_slot_index].add_popup(all_slots[selected_slot_index].item, "Joystick")
	elif all_slots[selected_slot_index].item and all_slots[selected_slot_index].popup != null and _isMandK and \
			all_slots[selected_slot_index].popup.source != "Mouse":
		all_slots[selected_slot_index].remove_popup()
		

func slot_gui_input(event: InputEvent, slot: slot_class):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if holding_item != null:
				if !slot.item: # place holding item into a slot
					left_click_place_item(slot)
				else: # swap holding item with item in slot
					left_click_swap_item(event, slot)
			elif slot.item: # left clicking an item while not currently holding an item
				left_click_select_item(slot)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if holding_item == null:
				if slot.item:
					right_click_use_item(slot)
	if event is InputEventJoypadButton:
		# TODO: match buttons to configured ones in options
		if event.button_index == JOY_BUTTON_A and event.pressed:
			if holding_item != null:
				if !slot.item: # place holding item into a slot
					left_click_place_item(slot, "Joystick")
				else: # swap holding item with item in slot
					left_click_swap_item(event, slot)
			elif slot.item: # left clicking an item while not currently holding an item
				left_click_select_item(slot)
		if event.button_index == JOY_BUTTON_X and event.pressed:
			if holding_item == null:
				if slot.item:
					right_click_use_item(slot)
		if event.button_index == JOY_BUTTON_B and event.pressed:
			if slot.item == null:
				return
			PlayerInventory.drop_item(slot.item.item, player)
			slot.item.queue_free()
			slot.item = null
			PlayerInventory.remove_item(slot)
			slot.remove_popup()
	SignalBus.inventory_changed.emit()

func _input(event):
	initialize_inventory()
	initialize_talisman()
	initialize_seeds()
	if holding_item:
		if _isMandK:
			holding_item.global_position = get_global_mouse_position()
		else:
			holding_item.global_position = selected_slot.global_position \
					+ Vector2(selected_slot.size.x * 2, selected_slot.size.y * 1.5)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#drop item if mouse is outside inventory and has a holding item after left mouse click
			if not player.mouse_in_inventory and holding_item != null:
				PlayerInventory.drop_item(holding_item.item, player)
				holding_item.queue_free()
				holding_item = null
				drop_delay.start() # delay to prevent shooting while dropping the item to the ground
	if event is InputEventMouseMotion or event is InputEventMouseButton or event is InputEventKey:
		_isMandK = true
	elif event is InputEventJoypadMotion:
		# only detect left joystick
		# TODO: change deadzone to match options menu value
		if Input.get_vector("left", "right", "up", "down").length() > 0.15 and \
				(event.get_axis() == 0 or event.get_axis() == 1):
			_isMandK = false
	elif event is InputEventJoypadButton:
		_isMandK = false
	# setup the controller navigation for the inventory
	if Input.is_action_just_pressed("inventory left"):
		selected_slot_index = max(0, selected_slot_index - 1)
		selected_slot.global_position = all_slots[selected_slot_index].global_position
		joystick_item_popup(selected_slot_index)
	if Input.is_action_just_pressed("inventory right"):
		selected_slot_index = min(all_slots.size() - 1, selected_slot_index + 1)
		selected_slot.global_position = all_slots[selected_slot_index].global_position
		joystick_item_popup(selected_slot_index)
	if Input.is_action_just_pressed("inventory up"):
		if selected_slot_index - 4 >= 0 or selected_slot_index == 3:
			selected_slot_index = max(0, selected_slot_index - 4)
			selected_slot.global_position = all_slots[selected_slot_index].global_position
			joystick_item_popup(selected_slot_index)
	if Input.is_action_just_pressed("inventory down"):
		if selected_slot_index + 4 < all_slots.size():
			selected_slot_index = min(all_slots.size() - 1, selected_slot_index + 4)
			selected_slot.global_position = all_slots[selected_slot_index].global_position
			joystick_item_popup(selected_slot_index)
	# adding an inventory select button to grab a slot item or slot a holding item
	if Input.is_action_just_pressed("inventory select"):
		var ev = InputEventJoypadButton.new()
		ev.button_index = JOY_BUTTON_A
		ev.pressed = true
		slot_gui_input(ev, all_slots[selected_slot_index])
	# adding a use/equip button
	if Input.is_action_just_pressed("inventory use"):
		var ev = InputEventJoypadButton.new()
		ev.button_index = JOY_BUTTON_X
		ev.pressed = true
		slot_gui_input(ev, all_slots[selected_slot_index])
	if Input.is_action_just_pressed("inventory drop"):
		var ev = InputEventJoypadButton.new()
		ev.button_index = JOY_BUTTON_B
		ev.pressed = true
		slot_gui_input(ev, all_slots[selected_slot_index])

func initialize_inventory():
	for i in range(inventory_slots.size()):
		if PlayerInventory.inventory.has(i):
			inventory_slots[i].initialize_item(PlayerInventory.inventory[i])

func initialize_talisman():
	for i in range(talisman_slots.size()):
		if PlayerInventory.talismans.has(i):
			talisman_slots[i].initialize_item(PlayerInventory.talismans[i])

func initialize_seeds():
	for i in range(seed_slots.size()):
		if PlayerInventory.seeds.has(i):
			seed_slots[i].initialize_item(PlayerInventory.seeds[i])

func able_to_put_into_slot(slot: slot_class) -> bool:
	if holding_item == null:
		return true
	# set the category as INVENTORY if there is no category property in the item resource
	# consumable items don't have a category property, so their category is always INVENTORY
	var holding_item_category = "INVENTORY" if not "category" in holding_item.item else holding_item.item.category
	# check the slot type of the slot
	if slot.slot_type == slot_class.slot_types.TALISMAN:
		return holding_item_category == "TALISMAN"
	elif slot.slot_type == slot_class.slot_types.SEED:
		return holding_item_category == "SEED"
	else: # if the category is INVENTORY (since inventory can fit anything, it will return true)
		return true

func left_click_place_item(slot: slot_class, source = "Mouse"): # place holding item into a slot
	if able_to_put_into_slot(slot):
		PlayerInventory.add_item_to_empty_slot(holding_item, slot)
		slot.put_into_slot(holding_item)
		slot.add_popup(holding_item, source)
		holding_item = null
		Global.save_run_data()

func left_click_swap_item(event: InputEvent, slot: slot_class): # swap holding item with item in selected slot
	if able_to_put_into_slot(slot):
		PlayerInventory.remove_item(slot)
		PlayerInventory.add_item_to_empty_slot(holding_item, slot)
		var temp_item = slot.item
		slot.pick_from_slot()
		if _isMandK:
			temp_item.global_position = event.global_position
		else:
			temp_item.global_position = selected_slot.global_position
		slot.put_into_slot(holding_item)
		holding_item = temp_item

func left_click_select_item(slot: slot_class): # left clicking an item while not currently holding an item
	PlayerInventory.remove_item(slot)
	holding_item = slot.item
	slot.pick_from_slot()
	slot.remove_popup()
	if holding_item:
		if _isMandK:
			holding_item.global_position = get_global_mouse_position()
		else:
			holding_item.global_position = selected_slot.global_position +\
			Vector2(selected_slot.size.x * 2, selected_slot.size.y * 1.5)

func right_click_use_item(slot: slot_class):
	if slot.item == null:
			return
	if slot.slot_type == slot_class.slot_types.INVENTORY:
		match slot.item.item.category:
			"CONSUMABLE":
				slot.item.item.on_use() # activate the use effect of the consumable item
				PlayerInventory.remove_item(slot) # then remove the item from the player inventory dictionary
				slot.item.queue_free.call_deferred() # then delete the item
				slot.remove_popup() # then remove the item description popup
			"TALISMAN":
				for inv_slot in talisman_slots:
					if !inv_slot.item:
						right_click_slot_item(slot, inv_slot)
						break
			"SEED":
				for inv_slot in seed_slots:
					if !inv_slot.item:
						right_click_slot_item(slot, inv_slot)
						break
	if slot.slot_type == slot_class.slot_types.TALISMAN or slot.slot_type == slot_class.slot_types.SEED:
		if PlayerInventory.get_empty_slot_index() != null:
			right_click_slot_item(slot, inventory_slots[PlayerInventory.get_empty_slot_index()])

func right_click_slot_item(selected_slot: slot_class, desired_slot: slot_class):
	var current_item = selected_slot.item
	PlayerInventory.remove_item(selected_slot)
	selected_slot.pick_from_slot()
	selected_slot.remove_popup()
	PlayerInventory.add_item_to_empty_slot(current_item, desired_slot)
	desired_slot.put_into_slot(current_item)
	Global.save_run_data()

func right_click_swap_item(selected_slot: slot_class, desired_slot: slot_class): # TODO: might be deleted later
	var current_item = selected_slot.item
	var swapping_item = desired_slot.item
	PlayerInventory.remove_item(selected_slot)
	PlayerInventory.remove_item(desired_slot)
	selected_slot.pick_from_slot()
	selected_slot.remove_popup()
	desired_slot.pick_from_slot()
	PlayerInventory.add_item_to_empty_slot(current_item, desired_slot)
	desired_slot.put_into_slot(current_item)
	PlayerInventory.add_item_to_empty_slot(swapping_item, selected_slot)
	selected_slot.put_into_slot(swapping_item)
	selected_slot.add_popup(swapping_item)
	Global.save_run_data()

func get_number_of_slots():
	return inventory_slots.size()

func joystick_item_popup(slot_index: int):
	if current_index_popup != slot_index:
		# removes current popup when the navigation box moves to a different slot
		if all_slots[current_index_popup].popup:
			all_slots[current_index_popup].remove_popup()
		# adds a new popup in the current slot the navigation box is in (if there is and item and no holding item)
		if all_slots[slot_index].item and holding_item == null:
			all_slots[slot_index].add_popup(all_slots[slot_index].item, "Joystick")
	current_index_popup = slot_index
