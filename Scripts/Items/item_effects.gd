extends Node

var passive_menu = preload("res://Scenes/UI/passive_choice.tscn")

func spawn_passive_menu():
	get_tree().current_scene.add_child(passive_menu.instantiate())

func dupe_items():
	var items = Targets.get_all_items()
	var coins = Targets.get_coins()
	for item in items:
		var duped_item = item.duplicate()
		get_tree().current_scene.add_child(duped_item)
		duped_item.global_position = item.global_position + Vector2.RIGHT * 32
	for item in coins:
		var duped_item = item.duplicate()
		get_tree().current_scene.add_child(duped_item)
		duped_item.global_position = item.global_position + Vector2.RIGHT * 32
	ItemCheck.check_for_items()
	ItemCheck.check_for_coins()
	await get_tree().create_timer(0.5).timeout
	Global.save_room()
