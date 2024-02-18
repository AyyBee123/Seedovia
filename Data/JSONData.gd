extends Node

var item_data: Dictionary

func _ready():
	item_data = LoadData("res://Data/ItemData.json")
	print(item_data)

func LoadData(file_path):
	var text = FileAccess.get_file_as_string(file_path)
	var dict = JSON.parse_string(text)
	return dict
	
