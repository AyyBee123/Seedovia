extends Node

var seeds_on_screen = []

func _physics_process(delta):
	seeds_on_screen = Targets.get_seeds()
	if seeds_on_screen.size() >= 75:
		seeds_on_screen[0].queue_free()
