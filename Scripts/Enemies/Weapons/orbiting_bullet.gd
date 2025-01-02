extends "res://Scripts/Enemies/Weapons/bullet.gd"

var total_distance := 0.0 # distance travelled (this is used for the weapon's range)
var radius := 0.0
var angle := 0.0
var starting_angle: float
var max_speed: float
var current_speed: float

func _ready():
	super._ready()
	max_speed = speed * 2
	current_speed = speed
	starting_angle = randf_range(0, 2 * PI)

func _physics_process(delta):
	initialize_position()
	travelled_distance()
	update_position(delta)

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(damage)
		queue_free()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= range:
		queue_free.call_deferred()

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += Vector2(
		sin(angle * speed + starting_angle) * radius,
		cos(angle * speed + starting_angle) * radius
	)
	speed = min(current_speed + delta * 2.5, max_speed)
	angle += delta * 0.05
	radius += delta * 2.5
