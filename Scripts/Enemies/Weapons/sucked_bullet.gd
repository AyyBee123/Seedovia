extends "res://Scripts/Enemies/Weapons/bullet.gd"

var source
var tween

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
		queue_free()
	if body.is_in_group("Enemies") and body.get_parent() == source:
		if source.animated_sprite_2d.animation == "Suck":
			tween = get_tree().create_tween()
			tween.tween_property(self, "scale", Vector2.ZERO, 0.25)
			tween.parallel().tween_property(self, "speed", 0, 0.25)
			tween.tween_callback(queue_free)
		else:
			queue_free()

func update_position(delta):
	if source:
		direction = global_position.direction_to(source.global_position)
	super.update_position(delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _exit_tree():
	if source:
		source.sucked_bullet_amount += 1
	if tween:
		tween.kill()
