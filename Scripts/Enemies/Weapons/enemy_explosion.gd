extends "res://Scripts/Passives/Effects/explosion.gd"

func _ready():
	collisions = 2
	super._ready()

func _on_area_2d_area_entered(area):
	pass

func _on_area_2d_body_entered(body):
	if is_vanity:
		return
	if body.is_in_group("Players"):
		body._player_stats.take_damage(damage)
