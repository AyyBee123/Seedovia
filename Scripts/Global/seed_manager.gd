extends Node

const MAX_SEEDS: int = 100
var seeds_on_screen := []

func add_projectile(seed):
	if not seed.is_in_group("Weapon to be Destroyed"):
		return
	
	# delete oldest if the limit is reached
	if seeds_on_screen.size() >= MAX_SEEDS:
		var oldest = seeds_on_screen[0]
		seeds_on_screen.remove_at(0)
		if is_instance_valid(oldest):
			oldest.queue_free()
	
	# add new projectile
	seeds_on_screen.append(seed)
