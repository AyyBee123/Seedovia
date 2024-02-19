extends Node2D

@export var item: Resource: set = set_item

var player_in_area = false
var player = null
const inventory = preload("res://Scripts/Inventory/inventory.gd")

func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("pick up"):
			pick_up()
			
func set_item(new_item: Resource):
	item = new_item
	$Sprite.texture = new_item.get_texture()

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		player_in_area = true
		player = body

func _on_pickable_area_body_exited(body):
	if body.is_in_group("Players"):
		player_in_area = false
		
func pick_up():
	PlayerInventory.add_item(item.get_item_name())
	queue_free()
	
func set_new_item(item_name):
	$Sprite.texture = load("res://Sprites/Items/" + item_name + ".png")
	item = load("res://Resources/Items/" + item_name + ".tres")
	

func find_child_by_type(type: String):
	for child in get_children():
		if child.get_class() == type:
			return child
