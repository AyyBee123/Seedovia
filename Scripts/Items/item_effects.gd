extends Node

var passive_menu = preload("res://Scenes/UI/passive_choice.tscn")

func spawn_passive_menu():
	get_tree().current_scene.add_child(passive_menu.instantiate())

func dupe_items():
	var item = Targets.get_all_items().pick_random()
	var duped_item = item.duplicate()
	get_tree().current_scene.add_child(duped_item)
	duped_item.global_position = item.global_position + Vector2.RIGHT * 32
	ItemCheck.check_for_items()
	ItemCheck.check_for_coins()
	await get_tree().create_timer(0.5).timeout
	Global.save_run_room()

func increase_rarity():
	var item = Targets.get_rarity_items().pick_random()
	var new_rarity = item.item.rarity + 1 # increase rarity by 1
	if item.item.category == "SEED" and new_rarity > 6:
		new_rarity = 0
	if item.item.category == "TALISMAN" and new_rarity > 5: # there are no mystic rarity talismans
		new_rarity = 0
	item.set_item(select_new_rarity_item(item.item, new_rarity))
	ItemCheck.check_for_items()
	await get_tree().create_timer(0.5).timeout
	Global.save_run_room()

func select_new_rarity_item(_item, _rarity):
	Global.RNG.randomize()
	var pool
	if _item.category == "SEED":
		pool = Pool.seed_list
	elif _item.category == "TALISMAN":
		pool = Pool.talisman_list
	if pool == null:
		return _item
	while _item.rarity != _rarity or not _item.unlocked:
		_item = ResourceLoader.load(pool.pick_random())
	return _item

func decrease_rarity():
	var item = Targets.get_rarity_items().pick_random()
	var new_rarity = item.item.rarity - 1 # decrease rarity by 1
	if item.item.category == "SEED" and new_rarity <= 0:
		new_rarity = 6
	if item.item.category == "TALISMAN" and new_rarity <= 0: # there are no mystic rarity talismans
		new_rarity = 5
	item.set_item(select_new_rarity_item(item.item, new_rarity))
	ItemCheck.check_for_items()
	await get_tree().create_timer(0.5).timeout
	Global.save_run_room()

func reroll_same_rarity():
	var item = Targets.get_rarity_items().pick_random()
	item.set_item(select_new_same_rarity(item.item))
	ItemCheck.check_for_items()
	await get_tree().create_timer(0.5).timeout
	Global.save_run_room()

func select_new_same_rarity(_item):
	Global.RNG.randomize()
	var pool
	var rarity = _item.rarity
	if _item.category == "SEED":
		pool = Pool.seed_list
	elif _item.category == "TALISMAN":
		pool = Pool.talisman_list
	elif _item.category == "CONSUMABLE":
		pool = Pool.consumable_list
	if pool == null:
		return _item
	_item = ResourceLoader.load(pool.pick_random())
	while _item.rarity != rarity or not _item.unlocked:
		_item = ResourceLoader.load(pool.pick_random())
	return _item

func reroll_doors():
	var doors = Targets.get_doors()
	Global.rewards.clear()
	for door in doors:
		if door.text == "Boss":
			continue
		door.set_reward()

func damage_enemies(_damage):
	var enemies = Targets.get_enemy_hitboxes()
	for enemy in enemies:
		enemy.get_parent()._enemy_stats.take_damage(_damage)
