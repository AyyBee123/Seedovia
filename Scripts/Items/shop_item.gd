extends Node2D

@export var item: Resource: set = set_item

@onready var radius = $"Pickable Area/Radius"
@onready var shadow = %Shadow

const inventory = preload("res://Scripts/Inventory/inventory.gd")

var player_in_area = false
var player = null
var price: int
var nearest_item: bool
var rarity_color
var hue = 0.0

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
			price = GlobalValues.talisman_prices[item.rarity]
		"SEED":
			price = GlobalValues.seed_prices[item.rarity]
		"PICKUP":
			price = item.shop_price
	$Price.text = "[center]¢" + str(price)

func _process(delta):
	match item.rarity:
		0: # Common
			set_values(Color(Color.DARK_GRAY, 0.2))
		1: # Uncommon
			set_values(Color(Color.LIGHT_SKY_BLUE, 0.5))
		2: # Rare
			set_values(Color("ffea81"))
		3: # Epic
			set_values(Color.BLUE_VIOLET)
		4: # Legendary
			set_values(Color.DARK_ORANGE)
		5: # Unique
			set_values(Color.CRIMSON)
		6: # Mystic
			var mystic_color
			mystic_color = Color.from_hsv(hue, 1.0, 1.0, 1.0)
			if hue < 1.0:
				hue += 0.0005
			else:
				hue = 0.0
			set_values(mystic_color)
		7: # N/A
			set_values(Color(Color.WHITE, 0))

func set_values(color):
	rarity_color = color
	if nearest_item:
		$Sprite.material.set("shader_parameter/color", Color(Color("ffff6e"), 1))
	else:
		$Sprite.material.set("shader_parameter/color", Color(rarity_color, 1))

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		player_in_area = true
		player = body

func _on_pickable_area_body_exited(body):
	if body.is_in_group("Players"):
		player_in_area = false
