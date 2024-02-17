extends Panel

var item_class = preload("res://Scenes/Inventory/Items/apple.tscn")
var item = null
var slot_index
@onready var panel = find_child("Panel")

#func _ready():
	#if randi() % 2 == 0:
		#item = item_class.instantiate()
		#panel.add_child(item)
		
func pick_from_slot():
	panel.remove_child(item)
	var inventory_node = find_parent("Inventory")
	inventory_node.add_child(item)
	item = null
	
func put_into_slot(new_item):
	item = new_item
	item.position = Vector2(0, 0)
	var inventory_node = find_parent("Inventory")
	inventory_node.remove_child(item)
	panel.add_child(item)
	
func initialize_item(item_name):
	if item == null:
		item = item_class.instantiate()
		panel.add_child(item)
		item.set_item(item_name)
	else:
		item.set_item(item_name)
