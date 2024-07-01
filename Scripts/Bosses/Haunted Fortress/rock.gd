extends "res://Scripts/Enemies/Weapons/bullet.gd"

var is_clockwise: bool
var destination: Vector2

func _ready():
	super._ready()
	is_clockwise = randi() % 1 == 1 # is either 0 or 1 (randomly). If it's 1, then it's true, otherwise it's false

func _physics_process(delta):
	super._physics_process(delta)
	if global_position.y <= destination.y:
		queue_free()

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta
	if is_clockwise:
		rotation_degrees += 2
	else:
		rotation_degrees -= 2
