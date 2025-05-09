extends Node

var seeds_on_screen = []

func _process(delta):
	seeds_on_screen = Targets.get_weapons_to_be_destroyed()
	if seeds_on_screen.size() > 100:
		seeds_on_screen[0].queue_free()
	if seeds_on_screen.size() > 150:
		seeds_on_screen[1].queue_free()
		seeds_on_screen[2].queue_free()
