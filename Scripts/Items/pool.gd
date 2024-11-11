extends Node

# item pools
var consumable_pool = ResourceLoader.load("res://Resources/Items/Pools/consumable_pool.tres")
var equipment_pool = ResourceLoader.load("res://Resources/Items/Pools/equipment_pool.tres")
var passive_pool = ResourceLoader.load("res://Resources/Items/Pools/passive_pool.tres")
var seed_pool = ResourceLoader.load("res://Resources/Items/Pools/seed_pool.tres")
var accumulated_weight: float # used to determine what item is chosen

var talisman_weights = {
	0: 0.40, # common
	1: 0.35, # uncommon
	2: 0.15, # rare
	3: 0.075, # epic
	4: 0.025, # legendary
	5: 0.0001, # mystic
	6: 1, # unique
	7: 1, # N/A
}

var seed_weights = {
	0: 0.40, # common
	1: 0.35, # uncommon
	2: 0.15, # rare
	3: 0.075, # epic
	4: 0.025, # legendary
	5: 0.0001, # mystic
	6: 1, # unique
	7: 1, # N/A
}
var consumable_weights = {
		7: 1
	}

#array of floor pools
var floors: Array
var boss_floors: Array

#pool arrays
var pools: Array

# condition to add specific pools to the array
var add_pool := true

func start():
	Global.RNG.randomize()
	talisman_weights = {
	0: 0.40, # common
	1: 0.35, # uncommon
	2: 0.15, # rare
	3: 0.075, # epic
	4: 0.025, # legendary
	5: 0.0001, # mystic
	6: 1, # unique
	7: 1, # N/A
	}
	seed_weights = {
	0: 0.40, # common
	1: 0.35, # uncommon
	2: 0.15, # rare
	3: 0.075, # epic
	4: 0.025, # legendary
	5: 0.0001, # mystic
	6: 1, # unique
	7: 1, # N/A
	}
	add_pool = true # add the pool array to the room reward pool
	populate_pool(equipment_pool, talisman_weights)
	populate_pool(consumable_pool, consumable_weights)
	populate_pool(seed_pool, seed_weights)
	add_pool = false
	if passive_pool.pool.size() == 0: # if one doesn't already exist from a current run save file
		populate_pool(passive_pool)
		shuffle_pool(passive_pool)
	add_floors()
	add_boss_floors()

func continue_run():
	talisman_weights = {
	0: 0.40 - min(LevelList.floor_number * 0.2, 0.4), # common
	1: 0.35 - min(LevelList.floor_number * 0.5, 0.35), # uncommon
	2: 0.15 + LevelList.floor_number * 0.01, # rare
	3: 0.075 + LevelList.floor_number * 0.015, # epic
	4: 0.025 + LevelList.floor_number * 0.015, # legendary
	5: 0.0001, # mystic
	6: 1, # unique
	7: 1, # N/A
	}
	seed_weights = {
	0: 0.40 - LevelList.floor_number * 0.05, # common
	1: 0.35 - LevelList.floor_number * 0.025, # uncommon
	2: 0.15 + LevelList.floor_number * 0.025, # rare
	3: 0.075 + LevelList.floor_number * 0.015, # epic
	4: 0.025 + LevelList.floor_number * 0.01, # legendary
	5: 0.0001, # mystic
	6: 1, # unique
	7: 1, # N/A
	}
	add_pool = true # add the pool array to the room reward pool
	populate_pool(equipment_pool, talisman_weights)
	populate_pool(consumable_pool, consumable_weights)
	populate_pool(seed_pool, seed_weights)
	add_pool = false
	add_floors()
	add_boss_floors()

func repopulate_weighted_pools():
	talisman_weights = {
	0: 0.40 - min(LevelList.floor_number * 0.2, 0.4), # common
	1: 0.35 - min(LevelList.floor_number * 0.5, 0.35), # uncommon
	2: 0.15 + LevelList.floor_number * 0.01, # rare
	3: 0.075 + LevelList.floor_number * 0.015, # epic
	4: 0.025 + LevelList.floor_number * 0.01, # legendary
	5: 0.0001, # mystic
	6: 1, # unique
	7: 1, # N/A
	}
	seed_weights = {
	0: 0.40 - LevelList.floor_number * 0.05, # common
	1: 0.35 - LevelList.floor_number * 0.025, # uncommon
	2: 0.15 + LevelList.floor_number * 0.025, # rare
	3: 0.075 + LevelList.floor_number * 0.015, # epic
	4: 0.025 + LevelList.floor_number * 0.01, # legendary
	5: 0.0001, # mystic
	6: 1, # unique
	7: 1, # N/A
	}
	equipment_pool.pool.clear()
	seed_pool.pool.clear()
	populate_pool(equipment_pool, talisman_weights)
	populate_pool(seed_pool, seed_weights)

func populate_pool(pool: Resource, weight: Dictionary = {}):
	accumulated_weight = 0
	var item_resources = get_all_file_paths(pool.path)
	for resource_path in item_resources:
		var item = ResourceLoader.load(resource_path)
		if "rarity" in item and weight.size() > 0:
			# take the current item weight and accumulate it
			accumulated_weight += weight[item.rarity]
			# take the current accumulated weight and assign it to the item
			item.acc_weight = accumulated_weight
			# take the current total item weight and assign it to the item pool
			pool.total_weight = accumulated_weight
		pool.pool.append(ResourceLoader.load(resource_path))
	pool.full_pool = pool.pool.duplicate()
	if add_pool:
		pools.append(pool)

func add_floors():
	var floor_files = get_all_file_paths("res://Resources/Floors/")
	for floor in floor_files:
		floors.append(ResourceLoader.load(floor))
	for floor in floors: # populate the rooms for each floor
		populate_pool(floor)

func add_boss_floors():
	if boss_floors.size() > 0:
		return
	var floor_files = get_all_file_paths("res://Resources/Boss Floors/")
	for floor in floor_files:
		boss_floors.append(ResourceLoader.load(floor))
	for floor in boss_floors: # populate the boss rooms for each floor
		populate_pool(floor)

func shuffle_pool(pool: Resource):
	pool.pool.shuffle()

func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			file_paths += get_all_file_paths(file_path)
		else:
			file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths

func get_item(pool: Resource):
	if pool.pool.is_empty(): # for the passives pool
		repopulate_pool(pool)
	if pool == passive_pool: # passive pool
		var item = pool.pool.pop_front()
		return item
	elif pool != consumable_pool and pool != equipment_pool and pool != seed_pool: # floor pools
		var item = pool.pool.pick_random()
		return item
	else: # talisman, seed, and consumable pools
		var roll: float = Global.RNG.randf_range(0.0, pool.total_weight)
		for item in pool.pool:
			if item.acc_weight > roll:
				return item

func repopulate_pool(pool: Resource):
	pool.pool = pool.full_pool.duplicate()
	shuffle_pool(pool)
