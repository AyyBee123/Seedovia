extends AnimatedSprite2D

signal doom_hit

var target
var tween

func _physics_process(delta):
	if not target:
		queue_free()
		return
	
	position.y = -150

func _on_duration_timeout():
	play("Slash")

func _on_animation_finished():
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", 200, 0.1).as_relative().set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		doom_hit.emit()
		queue_free()
	)

func _exit_tree():
	if tween:
		tween.kill()
