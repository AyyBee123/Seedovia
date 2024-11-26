extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

var collision
var direction

@export_range(-1, 1) var x_direction: int
@export_range(-1, 1) var y_direction: int

func _ready():
	super._ready()
	direction = Vector2(x_direction, y_direction)

func _physics_process(delta):
	super._physics_process(delta)
	velocity = velocity.lerp(_enemy_stats.speed * direction.normalized(), _enemy_stats.acceleration)
	collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		direction = velocity

func set_direction():
	pass
