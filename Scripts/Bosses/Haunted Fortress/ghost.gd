extends Sprite2D

var current_trail: trail
var direction = Vector2(1,0)
var current_velocity: Vector2
var speed: float = 200

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	make_trail()
	current_velocity = direction * speed
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func make_trail():
	current_trail = trail.create()
	add_child(current_trail)
