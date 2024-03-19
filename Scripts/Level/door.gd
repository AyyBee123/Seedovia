extends Node2D

var transition_scene = false
static var current_room_index = 0

func _physics_process(delta):
	if transition_scene:
		change_scene()

func _on_enter_radius_body_entered(body):
	if body.is_in_group("Players"):
		transition_scene = true

func _on_enter_radius_body_exited(body):
	if body.is_in_group("Players"):
		transition_scene = false

func change_scene():
	if current_room_index >= LevelList.floor1[1].size():
		current_room_index = 0
	get_tree().change_scene_to_packed(LevelList.floor1[1][current_room_index])
	current_room_index += 1
	Global.finish_change_scene()
