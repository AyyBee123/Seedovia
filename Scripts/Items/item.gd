extends Node2D

@export var i_stats: item_stats

var player_in_area = false
var player = null
const inventory = preload("res://Scripts/Inventory/inventory.gd")

func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("pick up"):
			pick_up()

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		player_in_area = true
		player = body

func _on_pickable_area_body_exited(body):
	if body.is_in_group("Players"):
		player_in_area = false
		
func pick_up():
	PlayerInventory.add_item(i_stats.item_name)
	queue_free()
	
func set_item(item_name):
	find_child_by_type("Sprite2D").texture = load("res://Sprites/Items/" + item_name + ".png")

func find_child_by_type(type: String):
	for child in get_children():
		if child.get_class() == type:
			return child
