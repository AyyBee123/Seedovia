extends Node

var equipment_path = "res://Resources/Items/Equipment/"
var consumables_path = "res://Resources/Items/Consumables/"
var seeds_path = "res://Resources/Items/Seeds/"
var passives_path = "res://Resources/Items/Passives/"

# first index is to identify the pool type. The second is to store all resources and pick from them
var equipment_pool := ["Equipment", []]
var consumable_pool := ["Consumable", []]
var passive_pool := ["Passive", []]
var seed_pool := ["Seed", []]

var full_equipment_pool: Array
var full_consumable_pool: Array
var full_passive_pool: Array
var full_seed_pool: Array

func _ready():
	randomize()
	populate_pool(LootPool.equipment_pool, LootPool.equipment_path)
	populate_pool(LootPool.consumable_pool, LootPool.consumables_path)
	populate_pool(LootPool.passive_pool, LootPool.passives_path)
	populate_pool(LootPool.seed_pool, LootPool.seeds_path)
	populate_full_pools()
	shuffle_pools()

func shuffle_pools():
	equipment_pool[1].shuffle()
	consumable_pool[1].shuffle()
	passive_pool[1].shuffle()
	seed_pool[1].shuffle()

func populate_pool(pool: Array, path: String):
	var item_resources = get_all_file_paths(path)
	for resource_path in item_resources:
		pool[1].append(ResourceLoader.load(resource_path))

func populate_full_pools():
	full_equipment_pool = equipment_pool[1].duplicate()
	full_consumable_pool = consumable_pool[1].duplicate()
	full_passive_pool = passive_pool[1].duplicate()
	full_seed_pool = seed_pool[1].duplicate()

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

func get_item(pool: Array):
	if pool[1].is_empty():
		repopulate_pool(pool)
	var item
	match pool[0]:
		"Equipment":
			item = equipment_pool[1].pop_front()
		"Consumable":
			item = consumable_pool[1].pop_front()
		"Passive":
			item = passive_pool[1].pop_front()
		"Seed":
			item = seed_pool[1].pop_front()
	return item

func repopulate_pool(pool: Array):
	match pool[0]:
		"Equipment":
			equipment_pool[1] = full_equipment_pool.duplicate()
			equipment_pool[1].shuffle()
		"Consumable":
			consumable_pool[1] = consumable_pool.duplicate()
			consumable_pool[1].shuffle()
		"Passive":
			passive_pool[1] = passive_pool.duplicate()
			passive_pool[1].shuffle()
		"Seed":
			seed_pool[1] = seed_pool.duplicate()
			seed_pool[1].shuffle()
