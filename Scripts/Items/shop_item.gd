extends Node2D

@export var item: Resource: set = set_item

var player_in_area = false
var player = null
var price: int
const inventory = preload("res://Scripts/Inventory/inventory.gd")
@onready var radius = $"Pickable Area/Radius"

var talisman_prices = {
	0: 10,
	1: 20,
	2: 30,
	3: 50,
	4: 100,
	5: 200
}

var seed_prices = {
	0: 15,
	1: 25,
	2: 40,
	3: 60,
	4: 120,
	5: 250
}

func _ready():
	radius.disabled = false
	set_price()

func set_item(new_item: Resource):
	item = new_item
	$Sprite.texture = new_item.get_texture()

func set_price():
	match item.category:
		"CONSUMABLE":
			price = item.shop_price
		"TALISMAN":
			price = talisman_prices[item.rarity]
		"SEED":
			price = seed_prices[item.rarity]
		"PICKUP":
			price = item.shop_price
	$Price.text = "[center]¢" + str(price)

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		player_in_area = true
		player = body

func _on_pickable_area_body_exited(body):
	if body.is_in_group("Players"):
		player_in_area = false
