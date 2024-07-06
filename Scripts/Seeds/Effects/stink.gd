extends Sprite2D

var direction: Vector2
var speed: float = 100
var current_velocity: Vector2

func _physics_process(delta):
	current_velocity = direction * speed
	position += current_velocity * delta
	#look_at(Vector2.RIGHT.rotated(randf_range(0, PI/6)))

func _on_timer_timeout():
	queue_free()
