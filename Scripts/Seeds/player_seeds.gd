extends Node

var seeds := []
var seed_indices := []

func load_weapons() -> Array:
	if PlayerInventory.seeds.size() == 0:
		return []
	var keys = PlayerInventory.seeds.keys()
	keys.sort()
	seeds = []
	seed_indices = []
	for i in keys:
		seed_indices.append(i)
		seeds.append(PlayerInventory.seeds[i].scene)
	return seeds

func get_weapon(index):
	return seeds[index]
