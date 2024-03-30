extends Node

var floor = ResourceLoader.load("res://Resources/Current Floor/floor.tres")
static var floor_number: int
static var room_number: int

func _ready():
	randomize()

func change_room():
	Global.save_data()
	if room_number == 4: # fifth room is the passive room
		floor.rooms.append(ResourceLoader.load("res://Scenes/Levels/Special/Passive Room.tscn"))
	elif room_number == 9: # room before the boss room
		floor.rooms.append(Pool.get_item(Pool.boss_floors[floor_number]))
	elif room_number >= 10: # next floor after the boss room
		change_floor()
	else:
		floor.rooms.append(Pool.get_item(Pool.floors[floor_number]))
	get_tree().change_scene_to_packed(floor.rooms[room_number])
	room_number = min(room_number + 1, 10)
	
func change_floor():
	Global.save_data()
	floor.rooms.clear()
	floor_number += 1
	room_number = 0
	floor.rooms.append(ResourceLoader.load("res://Scenes/Levels/Special/Starting Room.tscn"))
