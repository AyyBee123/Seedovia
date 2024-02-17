class_name inventory extends Resource

@export var items: Array[inventory_item]

signal update

func insert(item: inventory_item):
	var item_slots = items.filter(func(item): return item.item == item)
	if !item_slots.is_empty():
		print("inventory is full")
	else:
		var empty_slots = items.filter(func(item): return item.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
	update.emit()
