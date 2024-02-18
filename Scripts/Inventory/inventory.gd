extends Control

const slot_class = preload("res://Scripts/Inventory/inventory_slot.gd")
@onready var inventory_slots = $NinePatchRect/GridContainer
@onready var drop_button = $"NinePatchRect/Drop Button"
@onready var player := $"../Player"
var holding_item = null

func _ready():
	visible = false
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		slots[i].slot_index = i
	inititialize_inventory()
	
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
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i])
			
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
	var item_scene = load("res://Scenes/Items/" + item.i_stats.item_name.to_lower() + ".tscn")
	var current_item = item_scene.instantiate()
	get_tree().current_scene.add_child(current_item)
	current_item.global_position = player.global_position
	item.queue_free()
