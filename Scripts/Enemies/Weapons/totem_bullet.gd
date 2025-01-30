extends "res://Scripts/Enemies/Weapons/bullet.gd"

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
		queue_free()
