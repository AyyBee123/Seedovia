extends "res://Scripts/Bosses/boss.gd"

signal animation_done

@onready var animated_sprite_2d = $AnimatedSprite2D

func idle():
	pass

func laser():
	pass

func _on_animated_sprite_2d_animation_finished():
	animation_done.emit() # this is for the state machine to see if animation is done
