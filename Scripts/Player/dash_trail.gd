extends Sprite2D

var tween

func _ready():
	tween = get_tree().create_tween()
	
	tween.tween_property(self, "modulate:a", 0, 0.2)
	tween.parallel().tween_property(self, "scale", Vector2.ONE * 0.5, 0.2)
	tween.tween_callback(queue_free)
