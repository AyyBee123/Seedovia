extends Node

func load_weapon() -> PackedScene:
	for i in PlayerInventory.seeds:
		if PlayerInventory.seeds[i].scene == null:
			continue
		return PlayerInventory.seeds[i].scene
	return null
