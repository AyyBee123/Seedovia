extends Sprite2D

var speed
var rotate
var rotational_dir

func _ready():
	randomize()
	speed = randf_range(80, 100)
	rotate = randf_range(10, 20)
	rotational_dir = 1 if randf() < 0.5 else -1
	scale *= randf_range(0.8, 1)

func _physics_process(delta):
	position += Vector2.DOWN * speed * delta
	rotation_degrees += rotate * delta * rotational_dir
	
	if position.y >= 1000:
		queue_free()
