extends Node

var color
var hue: float

func _process(delta):
	color = Color.from_hsv(hue, 0.8, 0.8, 1.0)
	if hue < 1.0:
		hue += 0.01
	else:
		hue = 0.0
	get_parent().modulate = color
