extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var fire_rate = $"Fire Rate"

const LIQUID = preload("res://Scenes/Enemies/Weapons/Liquid.tscn")

func _physics_process(delta):
	super._physics_process(delta)
	if fire_rate.is_stopped():
		var liquid = LIQUID.instantiate()
		liquid.damage = damage
		get_tree().current_scene.add_child(liquid)
		liquid.global_position = global_position
		fire_rate.start()

func update_position(delta):
	super.update_position(delta)
	look_at(global_position + direction)

func _exit_tree():
	var liquid = LIQUID.instantiate()
	liquid.scale *= 2.5
	liquid.damage = damage
	get_tree().current_scene.add_child.call_deferred(liquid)
	liquid.global_position = global_position
