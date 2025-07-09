extends Node

const PICKUP_ITEM = preload("res://Scenes/Items/Pickup Item.tscn")

const NUMBER_OF_PRODUCE = 10

var player

func _ready():
	randomize()
	player = get_parent().get_parent()
	
	for i in NUMBER_OF_PRODUCE:
		var stat_up = PICKUP_ITEM.instantiate()
		stat_up.item = Pool.get_item(Pool.stat_up_pool)
		await get_tree().physics_frame # delay to make sure the correct player position is read
		get_tree().current_scene.add_child(stat_up)
		stat_up.global_position = player.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * 50
	
	queue_free()
