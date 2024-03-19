extends Node

var floor1 = ["Floor1", []]

func _ready():
	floor1[1].append(ResourceLoader.load("res://Scenes/Levels/Special/Starting Room.tscn"))
	for i in range(5):
		var room = LootPool.get_item(LootPool.floor1_pool)
		floor1[1].append(room)
