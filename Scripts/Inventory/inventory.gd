extends Control

const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")
const item_instance = preload("res://Scripts/Items/item.gd")
@onready var drop_button = $"NinePatchRect/Drop Button"
@onready var player = $"../Player"
@onready var inventory_slots = $"NinePatchRect/Inventory Slots".get_children()
@onready var equip_slots = $"NinePatchRect/Equipment Slots".get_children()
var holding_item = null # the item that is currently being held by the cursor in the inventory

func _ready():
	equip_slots.remove_at(2) # remove the second empty panel (Empty 2) from the array
	equip_slots.remove_at(0) # remove the first empty panel (Empty 0) from the array
	visible = false
	for i in range(inventory_slots.size()):
		inventory_slots[i].gui_input.connect(slot_gui_input.bind(inventory_slots[i]))
		inventory_slots[i].slot_index = i
		inventory_slots[i].slot_type = slot_class.slot_types.INVENTORY
		
	for i in range(equip_slots.size()):
		equip_slots[i].gui_input.connect(slot_gui_input.bind(equip_slots[i]))
		equip_slots[i].slot_index = i
	equip_slots[0].slot_type = slot_class.slot_types.HEAD
	equip_slots[1].slot_type = slot_class.slot_types.ARMS
	equip_slots[2].slot_type = slot_class.slot_types.BODY
	equip_slots[3].slot_type = slot_class.slot_types.SHOULDERS
	equip_slots[4].slot_type = slot_class.slot_types.LEGS
	equip_slots[5].slot_type = slot_class.slot_types.WAIST
	equip_slots[6].slot_type = slot_class.slot_types.FEET
	inititialize_inventory()
	inititialize_equipment()
	
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		# toggle inventory UI to open/close
		visible = not visible
		
func slot_gui_input(event: InputEvent, slot: slot_class):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if holding_item != null:
				if !slot.item: # place holding item into a slot
					left_click_place_item(slot)
				else: # swap holding item with item in slot
					left_click_swap_item(event, slot)
			elif slot.item: # left clicking an item while not currently holding an item
				left_click_select_item(slot)
				
func _input(event):
	inititialize_inventory()
	if holding_item:
		holding_item.global_position = get_global_mouse_position()
		
func inititialize_inventory():
	for i in range(inventory_slots.size()):
		if PlayerInventory.inventory.has(i):
			inventory_slots[i].initialize_item(PlayerInventory.inventory[i])
			
func inititialize_equipment():
	for i in range(equip_slots.size()):
		if PlayerInventory.equipment.has(i):
			equip_slots[i].initialize_item(PlayerInventory.equipment[i])
			
func left_click_place_item(slot: slot_class):
	PlayerInventory.add_item_to_empty_slot(holding_item, slot)
	slot.put_into_slot(holding_item)
	holding_item = null
	
func left_click_swap_item(event: InputEvent, slot: slot_class):
	PlayerInventory.remove_item(slot)
	PlayerInventory.add_item_to_empty_slot(holding_item, slot)
	var temp_item = slot.item
	slot.pick_from_slot()
	temp_item.global_position = event.global_position
	slot.put_into_slot(holding_item)
	holding_item = temp_item
	
func left_click_select_item(slot: slot_class):
	PlayerInventory.remove_item(slot)
	holding_item = slot.item
	slot.pick_from_slot()
	holding_item.global_position = get_global_mouse_position()
	
func _on_drop_button_pressed():
	if holding_item != null:
		drop_item(holding_item)
		holding_item = null
		
func drop_item(item):
	var item_scene = load("res://Scenes/Items/item.tscn")
	var current_item = item_scene.instantiate()
	current_item.set_item(item.item)
	get_tree().current_scene.add_child(current_item)
	current_item.global_position = player.global_position
	item.queue_free()
