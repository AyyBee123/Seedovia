extends "res://Scripts/Enemies/Slime/slime.gd"

const BIG_GOOP = preload("res://Scenes/Misc/Big Goop.tscn")

func goop():
	var goop = BIG_GOOP.instantiate()
	get_tree().current_scene.add_child(goop)
	goop.global_position = global_position
