extends Node2D

var player = null

@onready var resource_preloader := $ResourcePreloader

func _physics_process(delta):
	if player != null:
		position += global_position.direction_to(player.global_position) * delta * 600

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		pick_up()

func _on_attract_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body

func pick_up():
	spawn_passive_menu()
	queue_free()

func spawn_passive_menu():
	get_tree().current_scene.add_child(resource_preloader.get_resource("Passive Choice").instantiate())
