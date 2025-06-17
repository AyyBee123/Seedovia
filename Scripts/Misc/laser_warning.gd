extends Sprite2D

const LONG_LASER = preload("res://Scenes/Enemies/Weapons/Long Laser.tscn")

func _on_animation_player_animation_finished(anim_name):
	var laser = LONG_LASER.instantiate()
	get_tree().current_scene.add_child(laser)
	laser.global_position = global_position
	queue_free()
