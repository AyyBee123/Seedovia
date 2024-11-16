extends Panel

var item_instance = null
var item = null
var slot_index: int
var popup = null

@onready var player = $"../../../.."
@onready var inventory = $"../../.."
var item_popup = preload("res://Scenes/UI/Item Popup.tscn")

enum slot_types {
	INVENTORY,
	TALISMAN,
	SEED
}

var slot_type = null

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func pick_from_slot():
	if slot_type == slot_types.TALISMAN:
		PlayerEquipment.remove_stats(item, player, item.item.was_already_equipped)
		for passive in item.item.special_properties:
			var p = passive.instantiate()
			PlayerEquipment.remove_passive(player, p.name)
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
	if slot_type == slot_types.TALISMAN:
		PlayerEquipment.add_stats(item, player, item.item.was_already_equipped)
		for passive in item.item.special_properties:
			var p = passive.instantiate()
			PlayerEquipment.add_passive(player, p)
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
		if slot_type == slot_types.TALISMAN:
			if item.item.add_stats:
				PlayerEquipment.add_stats(item, player, item.item.was_already_equipped)
				for passive in item.item.special_properties:
					var p = passive.instantiate()
					PlayerEquipment.add_passive(player, p)
				item.item.was_already_equipped = true
				item.item.add_stats = false
				Global.save_data()
		add_child(item)
		item.scale = Vector2(1,1)
		item.position = Vector2(size.x / 2, size.y / 2)
		item.radius.disabled = true
	else:
		item.set_item(slot_item)

func _on_mouse_entered():
	if item != null && inventory.holding_item == null:
		add_popup(item)

func _on_mouse_exited():
	remove_popup()

func add_popup(item, source = "Mouse"):
	if popup != null:
		return
	popup = item_popup.instantiate()
	popup.item_name = item.item.item_name
	popup.type = item.item.category
	popup.description = item.item.description
	popup.rarity = item.item.rarity
	popup.inventory = inventory
	popup.source = source
	add_child.call_deferred(popup)

func remove_popup():
	if popup != null:
		remove_child.call_deferred(popup)
		popup.queue_free()
