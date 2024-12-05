extends Node2D

var player
@export var item: pickup_item_class: set = set_item

func _physics_process(delta):
	if player != null:
		position += global_position.direction_to(player.global_position) * delta * 600

func set_item(new_item: pickup_item_class):
	item = new_item
	$Sprite.texture = new_item.get_texture()

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		pick_up()

func _on_attract_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body

func pick_up():
	item.on_pickup()
	await get_tree().process_frame
	ItemCheck.check_for_pickup_items()
	Global.save_data()
	Global.save_room()
	queue_free()
