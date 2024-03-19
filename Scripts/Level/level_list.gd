extends Node

var floor = ResourceLoader.load("res://Resources/Current Floor/floor.tres")
static var floor_number := 0
static var room_number := 0

func _ready():
	randomize()

func change_room():
	Global.save_data()
	if room_number == 0: # first room is the starting room
		floor.rooms.append(ResourceLoader.load("res://Scenes/Levels/Special/Starting Room.tscn"))
	elif room_number == 4: # fifth room is the passive room
		floor.rooms.append(ResourceLoader.load("res://Scenes/Levels/Special/Passive Room.tscn"))
	else:
		floor.rooms.append(Pool.get_item(Pool.floors[floor_number]))
	get_tree().change_scene_to_packed(floor.rooms[room_number])
	Pool.shuffle_pool(Pool.floors[floor_number])
	room_number += 1
	
func change_floor():
	Global.save_data()
	floor.rooms.clear()
	floor_number += 1
	room_number = 0
