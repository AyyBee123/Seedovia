extends Control

const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")
@onready var player = $".."
@onready var inventory_slots = $"Inventory Screen/Inventory Slots".get_children()
@onready var talisman_slots = $"Inventory Screen/Talisman Slots".get_children()
@onready var seed_slots = $"Inventory Screen/Seed Slots".get_children()
@onready var selected_slot = $"Selected Slot"

var holding_item = null # the item that is currently being held by the cursor in the inventory
var drop_delay = Timer.new()
var _isMandK := true
# set the default selected slot (for controller inventory navigation)
var selected_slot_index: int

func _ready():
	add_child.call_deferred(drop_delay)
	drop_delay.one_shot = true
	drop_delay.wait_time = 0.1
	visible = false # make inventory not visible on starting the game
	# initialize all the inventory slots and their categories
	# connect each inventory slot with the slot_gui_input function, binding the slot as the unique identifier
	# gui_input is a built-in signal that is emitted when an input is pressed in the gui
	for i in range(inventory_slots.size()):
		inventory_slots[i].gui_input.connect(slot_gui_input.bind(inventory_slots[i]))
		inventory_slots[i].slot_index = i
		inventory_slots[i].slot_type = slot_class.slot_types.INVENTORY
	# initialize all the seed slots and their categories
	for i in range(seed_slots.size()):
		seed_slots[i].gui_input.connect(slot_gui_input.bind(seed_slots[i]))
		seed_slots[i].slot_index = i
		seed_slots[i].slot_type = slot_class.slot_types.SEED
	# initialize all the talisman slots
	for i in range(talisman_slots.size()):
		talisman_slots[i].gui_input.connect(slot_gui_input.bind(talisman_slots[i]))
		talisman_slots[i].slot_index = i
		talisman_slots[i].slot_type = slot_class.slot_types.TALISMAN
	
	# set the initial position and value of the (yellow) selected slot for controller
	selected_slot.global_position = inventory_slots[0].global_position
	selected_slot_index = 0
	
	inititialize_inventory()
	inititialize_talisman()
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
	if not visible and holding_item != null:
		PlayerInventory.add_item(holding_item.item, player, self)
		holding_item.queue_free()
		holding_item = null
	if visible:
		if not _isMandK:
			selected_slot.visible = true
		if _isMandK:
			selected_slot.visible = false

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

func _input(event):
	inititialize_inventory()
	inititialize_talisman()
	inititialize_seeds()
	if holding_item:
		holding_item.global_position = get_global_mouse_position()
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
		if Input.get_vector("left", "right", "up", "down").length() > 0.15 and\
		(event.get_axis() == 0 or event.get_axis() == 1):
			_isMandK = false
	elif event is InputEventJoypadButton:
		_isMandK = false

func inititialize_inventory():
	for i in range(inventory_slots.size()):
		if PlayerInventory.inventory.has(i):
			inventory_slots[i].initialize_item(PlayerInventory.inventory[i])

func inititialize_talisman():
	for i in range(talisman_slots.size()):
		if PlayerInventory.talismans.has(i):
			talisman_slots[i].initialize_item(PlayerInventory.talismans[i])

func inititialize_seeds():
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

func left_click_place_item(slot: slot_class): # place holding item into a slot
	if able_to_put_into_slot(slot):
		PlayerInventory.add_item_to_empty_slot(holding_item, slot)
		slot.put_into_slot(holding_item)
		slot.add_popup(holding_item)
		holding_item = null

func left_click_swap_item(event: InputEvent, slot: slot_class): # swap holding item with item in selected slot
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
	slot.remove_popup()
	holding_item.global_position = get_global_mouse_position()

func right_click_use_item(slot: slot_class):
	if slot.slot_type == slot_class.slot_types.INVENTORY:
		match slot.item.item.category:
			"CONSUMABLE":
				slot.item.item.on_use(Targets.player) # activate the use effect of the consumable item
				PlayerInventory.remove_item(slot) # then remove the item from the player inventory dictionary
				slot.item.call_deferred("free") # then delete the item
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

func get_number_of_slots():
	return inventory_slots.size()
