extends "res://Scripts/Enemies/Weapons/bullet.gd"

var source
var angle = 0
var starting_angle: float
var radius: float = 50
var new_radius: float # for the radius to lerp to
var t = 0
var LERP_AMOUNT = 0.05

func _ready():
	angle = starting_angle
	new_radius = radius

func _physics_process(delta):
	if not is_instance_valid(source):
		queue_free()
		return
	
	t += delta * LERP_AMOUNT
	radius = lerpf(radius, new_radius, t)
	
	angle += delta
	global_position = Vector2(
		sin(angle * speed + deg_to_rad(starting_angle)) * radius,
		cos(angle * speed + deg_to_rad(starting_angle)) * radius
	) + source.global_position

func travelled_distance():
	pass

func change_radius(_radius):
	new_radius = _radius
	t = 0
