extends "res://Scripts/Enemies/Weapons/homing_bullet.gd"

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const NUMBER_OF_BULLETS = 32

func _exit_tree():
	for i in NUMBER_OF_BULLETS:
		var bullet = BULLET.instantiate()
		bullet.damage = damage
		bullet.speed = speed
		bullet.range = range
		bullet.direction = Vector2.RIGHT.rotated(TAU / NUMBER_OF_BULLETS * i)
		Game.audio_manager.play(Game.audio_manager.big_laser)
		get_tree().current_scene.add_child.call_deferred(bullet)
		bullet.global_position = global_position + bullet.direction * 10
