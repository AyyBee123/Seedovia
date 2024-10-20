extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(delta):
	super._physics_process(delta)
	# if the player is to the left of the ghost
	if player.global_position < global_position:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true
	move_and_slide()
	var direction = player.global_position - self.global_position
	velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
