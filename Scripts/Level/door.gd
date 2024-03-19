extends Node2D

var transition_scene = false

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
	LevelList.change_room()
	Global.finish_change_scene()
