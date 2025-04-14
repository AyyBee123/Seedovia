extends Sprite2D

var tween

func _ready():
	randomize()
	scale = Vector2.ONE * randf_range(1, 2)
	modulate.a = 0
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.5, 1)

func _on_lifetime_timeout():
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.tween_callback(queue_free)
