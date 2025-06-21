extends "res://Scripts/Enemies/Weapons/bullet.gd"

func update_position(delta):
	super.update_position(delta)
	look_at(global_position + direction)

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
