extends Node

const ITEM = preload("res://Scenes/Items/Pickup Item.tscn")

var player

func _ready():
	player = get_parent().get_parent()
	
	var resource = Pool.stat_up_pool.pool.pick_random()
	var item = ITEM.instantiate()
	item.item = resource
	
	get_tree().current_scene.add_child(item)
	await get_tree().physics_frame
	item.global_position = player.global_position + Vector2(0, -200)
