extends Node

var seeds := []

func load_weapons(starting_index: int = 0) -> Array:
	if PlayerInventory.seeds.size() == 0:
		return []
	var keys = PlayerInventory.seeds.keys()
	keys.sort()
	seeds = []
	for i in keys:
		seeds.append(PlayerInventory.seeds[i].scene)
	return seeds
	
func get_weapon(index):
	return seeds[index]

