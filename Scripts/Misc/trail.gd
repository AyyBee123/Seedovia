extends Sprite2D

@onready var shrink_timer = $"Shrink Timer"
@onready var fade_timer = $"Fade Timer"
var size

func _ready():
	size = scale.y

func _physics_process(delta):
	scale.y = shrink_timer.time_left / shrink_timer.wait_time * size
	modulate.a = fade_timer.time_left / fade_timer.wait_time

func _on_shrink_timer_timeout():
	queue_free()
