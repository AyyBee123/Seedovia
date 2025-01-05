extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D

var mad_hat
var pos

func _ready():
	super._ready()
	$Hitbox/CollisionShape2D.disabled = true
	global_position = pos + mad_hat.animated_sprite_2d.global_position

func _physics_process(delta):
	super._physics_process(delta)

func idle():
	global_position = pos + mad_hat.animated_sprite_2d.global_position
	if mad_hat._state_machine.state == mad_hat._state_machine.states.idle:
		animated_sprite_2d.stop()
		animated_sprite_2d.frame = mad_hat.animated_sprite_2d.frame
	else:
		if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation != "Idle":
			animated_sprite_2d.play("Idle")

func slam():
	pass

func handpocalypse():
	pass

func charge():
	pass
