extends "res://Scripts/Enemies/Weapons/bullet.gd"

const ROTATION_SPEED = PI

var rotation_direction
var tween
var size

func _ready():
	size = scale
	randomize()
	super._ready()
	rotation_direction = -1 if randf() < 0.5 else 1
	scale *= 0.25
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", size, 0.5)

func update_position(delta):
	rotation += ROTATION_SPEED * delta * rotation_direction
	super.update_position(delta)

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _exit_tree():
	if tween:
		tween.kill()
