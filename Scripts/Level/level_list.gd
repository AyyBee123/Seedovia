extends Node

var floor = ResourceLoader.load("res://Resources/Current Floor/floor.tres")
static var floor_number: int
static var room_number: int
var current_room: String
var loaded_current_room: String
var loaded_room_is_cleared: bool
var current_reward_given: bool
var doors_spawned: bool
var next_room
var items_on_ground: Dictionary
var passive_items_on_ground: Dictionary
var picked_up_passive: bool
var doors: Dictionary

func change_room(door):
	Global.save_data()
	if door.text == "Passive": # fifth room is the passive room
		next_room = ResourceLoader.load("res://Scenes/Levels/Special/Passive Room.tscn")
	elif door.text == "Boss": # room before the boss room (10th room)
		next_room = Pool.get_item(Pool.boss_floors[floor_number])
	elif room_number >= 10: # next floor after the boss room
		change_floor()
	else:
		next_room = Pool.get_item(Pool.floors[floor_number])
	get_tree().change_scene_to_packed(next_room)
	doors_spawned = false
	current_reward_given = false
	picked_up_passive = false
	items_on_ground.clear()
	doors.clear()
	room_number = min(room_number + 1, 10)
	Global.save_room()

func change_floor():
	Global.save_data()
	floor.rooms.clear()
	floor_number += 1
	room_number = 0
	Pool.repopulate_weighted_pools()
	next_room = ResourceLoader.load("res://Scenes/Levels/Special/Starting Room.tscn")
