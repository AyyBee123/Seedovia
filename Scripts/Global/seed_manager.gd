extends Node

var seeds_on_screen = []

func _physics_process(delta):
	seeds_on_screen = Targets.get_weapons_to_be_destroyed()
	if seeds_on_screen.size() >= 80:
		seeds_on_screen[0].queue_free()
