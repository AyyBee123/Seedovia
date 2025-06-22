extends CharacterBody2D

var tween

func _on_lifetime_timeout():
	$CollisionShape2D.disabled = true
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.75)
	tween.tween_callback(queue_free)
