extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var metal_1_SFX = $Metal1
@onready var metal_2_SFX = $Metal2

var collision

func _physics_process(delta):
	super._physics_process(delta)
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		SfxDeconflicter.play(metal_1_SFX)

func launch_puck(direction):
	# direction is set from the Puncky enemy
	SfxDeconflicter.play(metal_2_SFX)
	velocity = direction * _enemy_stats.speed
