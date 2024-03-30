extends Node2D

@export var item: Resource: set = set_item

var player_in_area = false
var player = null
const inventory = preload("res://Scripts/Inventory/inventory.gd")

func _ready():
	scale = Vector2(1.5,1.5)

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
	PlayerInventory.add_item(item, player, inventory)
	queue_free()
