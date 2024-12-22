extends Node

@onready var impulse_time = $"Impulse Time"
@onready var deceleration_time = $"Deceleration Time"

var knockback_direction: Vector2
var knockback_speed: float
var player

func _ready():
	player = get_parent()

func _physics_process(delta):
	var collision
	if deceleration_time.is_stopped():
		player.velocity += knockback_direction * knockback_speed
	else:
		player.velocity += knockback_direction * knockback_speed * deceleration_time.time_left \
		/ deceleration_time.wait_time
	if collision:
		player.remove_child(self)
		queue_free.call_deferred()

func _on_impulse_time_timeout():
	if deceleration_time.is_stopped():
		deceleration_time.start()

func _on_deceleration_time_timeout():
	player.remove_child(self)
	queue_free.call_deferred()
