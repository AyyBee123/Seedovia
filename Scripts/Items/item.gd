extends Node2D

@export var item: Resource: set = set_item

@onready var radius = $"Pickable Area/Radius"
@onready var shadow = %Shadow
@onready var gpu_particles = %GPUParticles

const inventory = preload("res://Scripts/Inventory/inventory.gd")
const SPARKLE = preload("res://Scenes/Misc/Sparkle.tscn")

var player_in_area = false
var player = null
var hue = 0.0
var rarity_color
var nearest_item: bool

func _ready():
	scale = Vector2.ONE * 2
	radius.disabled = false
	%Shadow.visible = true
	%GPUParticles.visible = true
	
	for i in 8:
		match item.rarity:
			0: # Common
				spawn_sparkle(Color.DARK_GRAY)
			1: # Uncommon
				spawn_sparkle(Color.LIGHT_SKY_BLUE)
			2: # Rare
				spawn_sparkle(Color("ffea81"))
			3: # Epic
				spawn_sparkle(Color.BLUE_VIOLET)
			4: # Legendary
				spawn_sparkle(Color.DARK_ORANGE)
			5: # Unique
				spawn_sparkle(Color.CRIMSON)
			7: # N/A
				spawn_sparkle(Color.WHITE)
	
	if item.rarity == 6: # Mystic
		spawn_sparkle(Color("c80000"))
		spawn_sparkle(Color("c54500"))
		spawn_sparkle(Color("ccc100"))
		spawn_sparkle(Color("3cb400"))
		spawn_sparkle(Color("00bcbc"))
		spawn_sparkle(Color("000ab8"))
		spawn_sparkle(Color("6600b8"))
	
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
		7: # N/A
			set_values(Color(0, 0, 0, 0))

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
	%GPUParticles.modulate = color
	rarity_color = color
	if nearest_item:
		$Sprite.material.set("shader_parameter/color", Color(Color("ffff6e"), 1))
	else:
		$Sprite.material.set("shader_parameter/color", Color(rarity_color, 1))

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

func spawn_sparkle(color: Color):
	var sparkle = SPARKLE.instantiate()
	sparkle.modulate = color
	sparkle.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	add_child(sparkle)
	sparkle.global_position = global_position + sparkle.direction * 20
