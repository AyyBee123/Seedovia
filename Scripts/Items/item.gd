extends Node2D

@export var item: Resource: set = set_item

var player_in_area = false
var player = null
const inventory = preload("res://Scripts/Inventory/inventory.gd")
@onready var radius = $"Pickable Area/Radius"

func _ready():
	scale = Vector2.ONE * 2
	radius.disabled = false

func set_item(new_item: Resource):
	item = new_item
	$Sprite.texture = new_item.get_texture()

# TODO: add this in player script
func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		player_in_area = true
		player = body

func _on_pickable_area_body_exited(body):
	if body.is_in_group("Players"):
		player_in_area = false
