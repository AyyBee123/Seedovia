extends Node2D

signal weapon_fired(weapon)
signal has_collided(object)
signal attempted_fire


# these values are declared in the passive script that triggers the explosion
var object
var damage: float
var size: float
var damage_multiplier = 1
var source
var is_vanity := false
var weapon_direction = Vector2.ZERO

func _ready():
	scale = Vector2.ONE * size
	$AnimatedSprite2D.play("boom")
	if object == null:
		set_physics_process(false)

func _physics_process(delta):
	if object != null:
		global_position = object.global_position

func _on_animated_sprite_2d_animation_finished():
	queue_free()

func _on_area_2d_area_entered(area):
	if is_vanity:
		return
	has_collided.emit(area)
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(damage)
