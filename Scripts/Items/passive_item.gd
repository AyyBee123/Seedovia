extends Node2D

var player_in_area = false
var player = null

@onready var resource_preloader := $ResourcePreloader

func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("pick up"):
			pick_up()

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		player_in_area = true
		player = body

func _on_pickable_area_body_exited(body):
	if body.is_in_group("Players"):
		player_in_area = false
		
func pick_up():
	spawn_passive_menu()
	queue_free()

func spawn_passive_menu():
	get_tree().current_scene.add_child(resource_preloader.get_resource("Passive Choice").instantiate())
