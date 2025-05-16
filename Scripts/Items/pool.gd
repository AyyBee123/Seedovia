extends Node

# item pools
var consumable_pool = ResourceLoader.load("res://Resources/Items/Pools/consumable_pool.tres")
var equipment_pool = ResourceLoader.load("res://Resources/Items/Pools/equipment_pool.tres")
var passive_pool = ResourceLoader.load("res://Resources/Items/Pools/passive_pool.tres")
var seed_pool = ResourceLoader.load("res://Resources/Items/Pools/seed_pool.tres")
var pickup_pool = ResourceLoader.load("res://Resources/Items/Pools/pickup_pool.tres") # used in shops
var coin_pool = ResourceLoader.load("res://Resources/Items/Pools/coin_pool.tres")
var stat_up_pool = ResourceLoader.load("res://Resources/Items/Pools/stat_up_pool.tres")
var health_up_pool = ResourceLoader.load("res://Resources/Items/Pools/health_up_pool.tres")
var leaf_heart_pool = ResourceLoader.load("res://Resources/Items/Pools/leaf_heart_pool.tres")
var heal_pool = ResourceLoader.load("res://Resources/Items/Pools/heal_pool.tres")

# get list of items
@onready var seed_list = get_all_file_paths("res://Resources/Items/Seeds/")
@onready var talisman_list = get_all_file_paths("res://Resources/Items/Equipment/")
@onready var consumable_list = get_all_file_paths("res://Resources/Items/Consumables/")

# for the White Shrub character when they start a run
var white_shrub_seed_pool = ResourceLoader.load("res://Resources/Items/Pools/white_chaos_seed_pool.tres")
var white_shrub_talisman_pool = ResourceLoader.load("res://Resources/Items/Pools/white_chaos_equipment_pool.tres")

var accumulated_weight: float # used to determine what item is chosen

var talisman_weights = {
	0: 0.40, # common
	1: 0.35, # uncommon
	2: 0.15, # rare
	3: 0.075, # epic
	4: 0.025, # legendary
	5: 0.0001, # mystic
	6: 0, # unique
	7: 0, # N/A
}

var seed_weights = {
	0: 0.40, # common
	1: 0.35, # uncommon
	2: 0.15, # rare
	3: 0.075, # epic
	4: 0.025, # legendary
	5: 0.0001, # mystic
	6: 0, # unique
	7: 0, # N/A
}

var consumable_weights = {
	7: 1
}

var white_shrub_talisman_weights = {
	0: 0.40, # common
	1: 0.35, # uncommon
	2: 0.15, # rare
	3: 0.075, # epic
	4: 0.025, # legendary
	5: 0.0001, # mystic
	6: 0.005, # unique
	7: 0, # N/A
}

var white_shrub_seed_weights = {
	0: 0.40, # common
	1: 0.35, # uncommon
	2: 0.15, # rare
	3: 0.075, # epic
	4: 0.025, # legendary
	5: 0.0001, # mystic
	6: 0.005, # unique
	7: 0, # N/A
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
	6: 0, # unique
	7: 0, # N/A
	}
	seed_weights = {
	0: 0.40, # common
	1: 0.35, # uncommon
	2: 0.15, # rare
	3: 0.075, # epic
	4: 0.025, # legendary
	5: 0.0001, # mystic
	6: 0, # unique
	7: 0, # N/A
	}
	
	if OS.has_feature("demo"):
		var consumable_pool = ResourceLoader.load("res://Resources/Demo/consumable_pool.tres")
		var equipment_pool = ResourceLoader.load("res://Resources/Demo/equipment_pool.tres")
		var passive_pool = ResourceLoader.load("res://Resources/Demo/passive_pool.tres")
		var seed_pool = ResourceLoader.load("res://Resources/Demo/seed_pool.tres")
	
	add_pool = true # add the pool array to the room reward pool
	populate_pool(equipment_pool, talisman_weights)
	populate_pool(consumable_pool, consumable_weights)
	populate_pool(seed_pool, seed_weights)
	populate_pool(coin_pool)
	populate_pool(stat_up_pool)
	populate_pool(health_up_pool)
	populate_pool(leaf_heart_pool)
	populate_pool(heal_pool)
	add_pool = false
	populate_pool(pickup_pool)
	populate_pool(white_shrub_seed_pool, white_shrub_seed_weights)
	populate_pool(white_shrub_talisman_pool, white_shrub_talisman_weights)
	
	passive_pool.pool.clear()
	populate_pool(passive_pool)
	shuffle_pool(passive_pool)
	
	add_floors()
	add_boss_floors()

func continue_run():
	talisman_weights = {
	0: 0.40 - min(LevelList.floor_number * 0.20, 0.40), # common
	1: 0.35 - min(LevelList.floor_number * 0.05, 0.35), # uncommon
	2: 0.15 + LevelList.floor_number * 0.01, # rare
	3: 0.075 + LevelList.floor_number * 0.015, # epic
	4: 0.025 + LevelList.floor_number * 0.015, # legendary
	5: 0.0001, # mystic
	6: 0, # unique
	7: 0, # N/A
	}
	seed_weights = {
	0: 0.40 - LevelList.floor_number * 0.05, # common
	1: 0.35 - LevelList.floor_number * 0.025, # uncommon
	2: 0.15 + LevelList.floor_number * 0.025, # rare
	3: 0.075 + LevelList.floor_number * 0.015, # epic
	4: 0.025 + LevelList.floor_number * 0.01, # legendary
	5: 0.0001, # mystic
	6: 0, # unique
	7: 0, # N/A
	}
	
	if OS.has_feature("demo"):
		var consumable_pool = ResourceLoader.load("res://Resources/Demo/consumable_pool.tres")
		var equipment_pool = ResourceLoader.load("res://Resources/Demo/equipment_pool.tres")
		var passive_pool = ResourceLoader.load("res://Resources/Demo/passive_pool.tres")
		var seed_pool = ResourceLoader.load("res://Resources/Demo/seed_pool.tres")
	
	add_pool = true # add the pool array to the room reward pool
	populate_pool(equipment_pool, talisman_weights)
	populate_pool(consumable_pool, consumable_weights)
	populate_pool(seed_pool, seed_weights)
	populate_pool(coin_pool)
	populate_pool(stat_up_pool)
	populate_pool(health_up_pool)
	populate_pool(leaf_heart_pool)
	populate_pool(heal_pool)
	add_pool = false
	populate_pool(pickup_pool)
	add_floors()
	add_boss_floors()

func repopulate_weighted_pools():
	talisman_weights = {
	0: 0.40 - min(LevelList.floor_number * 0.20, 0.40), # common
	1: 0.35 - min(LevelList.floor_number * 0.05, 0.35), # uncommon
	2: 0.15 + LevelList.floor_number * 0.01, # rare
	3: 0.075 + LevelList.floor_number * 0.015, # epic
	4: 0.025 + LevelList.floor_number * 0.01, # legendary
	5: 0.0001, # unique
	6: 0, # mystic
	7: 0, # N/A
	}
	seed_weights = {
	0: 0.40 - LevelList.floor_number * 0.05, # common
	1: 0.35 - LevelList.floor_number * 0.025, # uncommon
	2: 0.15 + LevelList.floor_number * 0.025, # rare
	3: 0.075 + LevelList.floor_number * 0.015, # epic
	4: 0.025 + LevelList.floor_number * 0.01, # legendary
	5: 0, # unique
	6: 0.0001, # mystic
	7: 0, # N/A
	}
	equipment_pool.pool.clear()
	seed_pool.pool.clear()
	add_pool = false # just to be sure
	populate_pool(equipment_pool, talisman_weights)
	populate_pool(seed_pool, seed_weights)

func populate_pool(pool: Resource, weight: Dictionary = {}):
	accumulated_weight = 0
	var item_resources = get_all_file_paths(pool.path)
	for resource_path in item_resources:
		var item = ResourceLoader.load(resource_path)
		if "unlocked" in item:
			if not item.unlocked: # don't add locked items to the pool
				continue
		if weight.size() > 0:
			# take the current item weight and accumulate it
			if "rarity" in item: # seeds and talismans
				accumulated_weight += weight[item.rarity]
				# take the current accumulated weight and assign it to the item
				item.acc_weight = accumulated_weight
				# take the current total item weight and assign it to the item pool
				pool.total_weight = accumulated_weight
		elif "weight" in item: # consumables and pickups
			accumulated_weight += item.weight
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
		if file_name.ends_with(".remap"):
			file_name = file_name.replace(".remap", "")
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
