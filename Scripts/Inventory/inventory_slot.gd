extends Panel

var item_instance = null
var item = null
var slot_index: int

@onready var player = $"../../../.."
@onready var player_stats_ui = get_tree().current_scene.get_node("Player Stats")

enum slot_types {
	INVENTORY,
	HEAD,
	ARMS,
	BODY,
	SHOULDERS,
	LEGS,
	WAIST,
	FEET,
	SEED
}

var slot_type = null

func pick_from_slot():
	if not (slot_type == slot_types.INVENTORY or slot_type == slot_types.SEED):
		PlayerEquipment.remove_stats(item, player, item.item.was_already_equipped)
		player_stats_ui.initialize_stats()
	if slot_type == slot_types.SEED:
		player.update_timers()
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
	if not (slot_type == slot_types.INVENTORY or slot_type == slot_types.SEED):
		PlayerEquipment.add_stats(item, player, item.item.was_already_equipped)
		item.item.was_already_equipped = true
		player_stats_ui.initialize_stats()
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
		item.position = Vector2(size.x / 2, size.y / 2)
	else:
		item.set_item(slot_item)
