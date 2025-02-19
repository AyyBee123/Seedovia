extends Node2D

var size: float
var source

func _ready():
	scale = Vector2.ONE * size

func _on_animated_sprite_2d_animation_finished():
	queue_free()
