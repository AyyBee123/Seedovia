extends "res://Scripts/Enemies/Weapons/bullet.gd"

const ROTATION_SPEED = TAU

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta
	rotation += ROTATION_SPEED * delta
