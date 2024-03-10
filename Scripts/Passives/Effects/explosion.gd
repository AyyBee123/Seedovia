extends Node2D

# these values are declared in the passive script that triggers the explosion
var object
var damage: float
var size: float

func _ready():
	scale = Vector2(size, size)
	if object == null:
		set_physics_process(false)

func _physics_process(delta):
	global_position = object.global_position

func _on_animated_sprite_2d_animation_finished():
	queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(damage)
