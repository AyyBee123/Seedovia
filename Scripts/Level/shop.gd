extends "res://Scripts/Level/Level.gd"

var shop_size: int
var current_shop_items = []

func _ready():
	super._ready()
	if not LevelList.shop_items_spawned:
		set_shop_items()
		LevelList.shop_items_spawned = true
	Global.save_room()

func set_shop_items():
	shop_size = randi_range(6, 8)
	var shop_item_categories = []
	shop_item_categories.append("Pickup")
	shop_item_categories.append("Consumable") # will be replaced with "pickup" when that's added
	shop_item_categories.append("Consumable")
	shop_item_categories.append("Consumable")
	# for sort order in the shop (right-to-left, bottom-to-top)
	if shop_size == 6:
		shop_item_categories.append("Talisman")
		shop_item_categories.append("Seed")
	elif shop_size == 7:
		shop_item_categories.append("Talisman")
		shop_item_categories.append("Talisman")
		shop_item_categories.append("Seed")
	elif shop_size == 8:
		shop_item_categories.append("Talisman")
		shop_item_categories.append("Talisman")
		shop_item_categories.append("Seed")
		shop_item_categories.append("Seed")
	for item_category in shop_item_categories:
		var item = resource_preloader.get_resource("Shop Item").instantiate()
		var pool: item_pool
		match item_category:
			"Consumable":
				pool = Pool.consumable_pool
			"Talisman":
				pool = Pool.equipment_pool
			"Seed":
				pool = Pool.seed_pool
			"Pickup":
				pool = Pool.pickup_pool
		item.set_item(Pool.get_item(pool))
		# prevents seeds and talismans in the player's inventory from being chosen
		# also prevents shop items from selling the same item twice
		while player_has_item(item) or shop_has_item(item):
			item.set_item(Pool.get_item(pool))
		current_shop_items.append(item)
	
	var first_four_positions = [150, 50, -50, -150]
	var index = 0
	for item in current_shop_items:
		add_child(item)
		if index < 4:
			item.global_position = Vector2(first_four_positions[index], 50)
		else:
			item.global_position = Vector2((shop_size - 4) * 150.0 / 4 - 100 * (index - 4), -50)
		index += 1
	check_for_shop_items()
	Global.save_room()


func player_has_item(shop_item) -> bool:
	if shop_item.item.category == "CONSUMABLE": # don't care if there are duplicate consumables
		return false
	var possesions = []
	# get all items the player has in their inventory and put them in an array
	for item in PlayerInventory.inventory.values():
		possesions.append(item)
	for item in PlayerInventory.seeds.values():
		possesions.append(item)
	for item in PlayerInventory.talismans.values():
		possesions.append(item)
	
	for possesion in possesions:
		if shop_item.item.item_name == possesion.item_name: # check if there are duplicates
			return true
	return false


func shop_has_item(shop_item) -> bool:
	if shop_item.item.category == "CONSUMABLE": # for now, since there is only one consumable item
		return false
	for item in current_shop_items:
		if shop_item.item.item_name == item.item.item_name: # check if there are duplicates
			return true
	return false
