extends Node

var passive_menu = preload("res://Scenes/UI/passive_choice.tscn")

func spawn_passive_menu():
	get_tree().current_scene.add_child(passive_menu.instantiate())
