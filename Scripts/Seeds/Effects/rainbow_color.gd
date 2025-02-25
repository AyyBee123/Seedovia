extends Node

var color
static var hue: float

func _process(delta):
	color = Color.from_hsv(hue, 0.8, 1.0, 1.0)
	if hue < 1.0:
		hue += 0.001
	else:
		hue = 0.0
	get_parent().modulate = color
