extends Panel

var item_class = preload("res://Scenes/Items/apple.tscn") # load any item scene
var item = null
var slot_index

func pick_from_slot():
	remove_child(item)
	var inventory_node = find_parent("Inventory")
	inventory_node.add_child(item)
	item = null
	
func put_into_slot(new_item):
	item = new_item
	item.position = Vector2(size.x / 2, size.y / 2)
	var inventory_node = find_parent("Inventory")
	inventory_node.remove_child(item)
	add_child(item)
	
func initialize_item(item_name):
	if item == null:
		item = item_class.instantiate()
		add_child(item)
		item.position = Vector2(size.x / 2, size.y / 2)
		item.set_item(item_name)
	else:
		item.set_item(item_name)
