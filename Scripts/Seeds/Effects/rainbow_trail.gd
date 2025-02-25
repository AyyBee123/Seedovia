extends Sprite2D

var tween

func _ready():
	tween = get_tree().create_tween()
	
	tween.tween_property(self, "modulate:a", 0, 0.075)
	tween.tween_callback(queue_free)
