extends "res://Scripts/Seeds/seed_template.gd"

# these values are declared in the passive script that triggers the explosion
var object

func _ready():
	scale = Vector2.ONE * SIZE
	$AnimatedSprite2D.play("boom")
	if object == null:
		set_physics_process(false)
	$Area2D.set_collision_mask(collisions)

func _physics_process(delta):
	if object != null:
		global_position = object.global_position

func _on_animated_sprite_2d_animation_finished():
	destroy()

func travelled_distance():
	pass

func _on_area_2d_area_entered(area):
	has_collided.emit(area)
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(DAMAGE)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Players"):
		body._player_stats.take_damage(1)
