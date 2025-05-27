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

#func _process(delta):
	#seeds_on_screen = Targets.get_weapons_to_be_destroyed()
	#if seeds_on_screen.size() > 100:
		#seeds_on_screen[0].queue_free()
	#if seeds_on_screen.size() > 150:
		#seeds_on_screen[1].queue_free()
		#seeds_on_screen[2].queue_free()
