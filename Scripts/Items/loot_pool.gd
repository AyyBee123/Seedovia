extends Node

# item pools
var consumable_pool = ResourceLoader.load("res://Resources/Items/Item Pools/consumable_pool.tres")
var equipment_pool = ResourceLoader.load("res://Resources/Items/Item Pools/equipment_pool.tres")
var passive_pool = ResourceLoader.load("res://Resources/Items/Item Pools/passive_pool.tres")
var seed_pool = ResourceLoader.load("res://Resources/Items/Item Pools/seed_pool.tres")

#room pools
var floor1_pool = ResourceLoader.load("res://Resources/Items/Item Pools/floor1.tres")

func _ready():
	randomize()
	populate_pool(equipment_pool)
	populate_pool(consumable_pool)
	populate_pool(passive_pool)
	populate_pool(seed_pool)
	populate_pool(floor1_pool)
	

func populate_pool(pool: Resource):
	var item_resources = get_all_file_paths(pool.path)
	for resource_path in item_resources:
		pool.pool.append(ResourceLoader.load(resource_path))
	pool.pool.shuffle()
	pool.full_pool = pool.pool.duplicate()

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
	if pool.pool.is_empty():
		repopulate_pool(pool)
	var item
	item = pool.pool.pop_front()
	return item

func repopulate_pool(pool: Resource):
	pool.pool = pool.full_pool.duplicate()
	pool.pool.shuffle()
