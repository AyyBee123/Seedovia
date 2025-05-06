extends "res://Scripts/Seeds/seed_template.gd"

@onready var quiet_thud_SFX = $QuietThud

func _ready():
	super._ready()
	texture = source.find_child("Hand").texture
	$Sprite2D.texture = texture

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	else:
		SfxDeconflicter.play(quiet_thud_SFX)
		queue_free()
	SfxDeconflicter.play(quiet_thud_SFX)
