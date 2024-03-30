extends Panel

var item_instance = null
var item = null
var slot_index: int

@onready var player = $"../../../.."

enum slot_types {
	INVENTORY,
	HEAD,
	ARMS,
	BODY,
	LEGS,
	SEED
}

var slot_type = null

func pick_from_slot():
	if not (slot_type == slot_types.INVENTORY or slot_type == slot_types.SEED):
		PlayerEquipment.remove_stats(item, player, item.item.was_already_equipped)
	remove_child(item)
	var inventory_node = find_parent("Inventory")
	inventory_node.add_child(item) # inventory node adds the child to be held by the mouse curser
	item = null
	if slot_type == slot_types.SEED:
		PlayerSeeds.load_weapons()
		player.update_timers()
	
func put_into_slot(new_item):
	item = new_item
	item.position = Vector2(size.x / 2, size.y / 2)
	var inventory_node = find_parent("Inventory")
	inventory_node.remove_child(item) # inventory node removes the child to be placed by the mouse curser to the slot
	add_child(item)
	if not (slot_type == slot_types.INVENTORY or slot_type == slot_types.SEED):
		PlayerEquipment.add_stats(item, player, item.item.was_already_equipped)
		item.item.was_already_equipped = true
	if slot_type == slot_types.SEED:
			PlayerSeeds.load_weapons()
			player.update_timers()

func initialize_item(slot_item):
	item_instance = load("res://Scenes/Items/item.tscn")
	if item == null:
		item = item_instance.instantiate()
		item.set_item(slot_item)
		if slot_type == slot_types.SEED:
			PlayerSeeds.load_weapons()
		add_child(item)
		item.scale = Vector2(1,1)
		item.position = Vector2(size.x / 2, size.y / 2)
	else:
		item.set_item(slot_item)
