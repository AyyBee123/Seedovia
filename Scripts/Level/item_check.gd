extends Node

func check_for_pickup_items():
	LevelList.pickup_items_on_ground.clear()
	var i = 0
	# check all direct children of the scene (i.e. all nodes on the ground)
	for item in get_tree().current_scene.get_children():
		# get the item and its current position, stored as a dictionary
		if item.is_in_group("Pickup Item"):
			LevelList.pickup_items_on_ground[i] = {
				"item": item.item,
				"position": item.global_position
			}
			i += 1

func check_for_items():
	LevelList.items_on_ground.clear()
	var i = 0
	# check all direct children of the scene (i.e. all nodes on the ground)
	for item in get_tree().current_scene.get_children():
		# get the item and its current position, stored as a dictionary
		if item.is_in_group("Item"):
			LevelList.items_on_ground[i] = {
				"item": item.item, 
				"position": item.global_position
			}
			i += 1

func check_for_shop_items():
	LevelList.shop_items_on_ground.clear()
	var i = 0
	# check all direct children of the scene (i.e. all nodes on the ground)
	for item in get_tree().current_scene.get_children():
		# get the item and its current position, stored as a dictionary
		if item.is_in_group("Shop Item"):
			LevelList.shop_items_on_ground[i] = {
				"item": item.item,
				"position": item.global_position
			}
			i += 1

func check_for_coins():
	LevelList.coins_on_ground.clear()
	var i = 0
	# check all direct children of the scene (i.e. all nodes on the ground)
	for item in get_tree().current_scene.get_children():
		# get the item and its current position, stored as a dictionary
		if item.is_in_group("Coin"):
			LevelList.coins_on_ground[i] = {
				"item": item,
				"position": item.global_position
			}
			i += 1
