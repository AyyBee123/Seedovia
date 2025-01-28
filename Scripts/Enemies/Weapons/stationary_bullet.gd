extends "res://Scripts/Enemies/Weapons/bullet.gd"

func _on_lifetime_timeout():
	queue_free()
