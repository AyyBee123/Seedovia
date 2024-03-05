extends Node

var equipment_path = "res://Resources/Items/Equipment/"
var consumables_path = "res://Resources/Items/Consumables/"
var seeds_path = "res://Resources/Items/Seeds/"
var passives_path = "res://Resources/Items/Passives/"

var equipment_pool := {}
var consumable_pool := {}
var passive_pool := {}
var seed_pool := {}

func populate_pool(pool: Dictionary, path: String):
	var item_resources = get_all_file_paths(path)
	for resource_path in item_resources:
		pool[pool.size()] = ResourceLoader.load(resource_path)
	
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
