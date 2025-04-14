extends ColorRect

const FLOOR_4_SPARKLE = preload("res://Scenes/Misc/Floor 4 Sparkle.tscn")

const SPAWN_RATE = 0.5

var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = SPAWN_RATE
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	var sparkle = FLOOR_4_SPARKLE.instantiate()
	var vp = get_viewport().size / 2
	get_tree().current_scene.add_child(sparkle)
	sparkle.global_position = Vector2(randf_range(-vp.x, vp.x), randf_range(-vp.y, vp.y))
	timer.start()
