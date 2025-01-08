extends Node2D

const HAT = preload("res://Scenes/Enemies/Weapons/Hat.tscn")

const SPREAD = PI/6 # 30 degrees

var NUMBER_OF_HATS: int = 0
var INDEX: int = 0
var angle = 0.0
var radius = 321
var direction: Vector2

func _ready():
	while angle < TAU:
		var hat = HAT.instantiate()
		hat.radius = radius
		hat.index = INDEX
		add_child(hat)
		hat.position = (Vector2.RIGHT * radius).rotated(angle)
		angle += SPREAD
		NUMBER_OF_HATS += 1
		INDEX += 1

func _physics_process(delta):
	global_position.x += 250 * delta * direction.x

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
