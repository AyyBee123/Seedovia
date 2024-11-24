extends Node2D

var player = null
@export var item: pickup_item_class: set = set_item

func _physics_process(delta):
	if player != null:
		position += global_position.direction_to(player.global_position) * delta * 600

func set_item(new_item: pickup_item_class):
	item = new_item
	$Sprite.texture = new_item.get_texture()

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		pick_up()

func _on_attract_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body

func pick_up():
	item.on_pickup()
	await get_tree().create_timer(0.1).timeout
	check_for_pickup_items()
	Global.save_data()
	Global.save_room()
	queue_free()

func check_for_pickup_items():
	LevelList.pickup_items_on_ground.clear()
	var i = 0
	# check all direct children of the scene (i.e. all nodes on the ground)
	for item in get_children():
		# get the item and its current position, stored as a dictionary
		if item.is_in_group("Pickup Item"):
			LevelList.pickup_items_on_ground[i] = {
				"item": item.item,
				"position": item.global_position
			}
			i += 1
