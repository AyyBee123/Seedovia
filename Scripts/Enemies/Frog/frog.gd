extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var launch_delay = $"Launch Delay"
@onready var _state_machine = $state_machine

const FROG_TONGUE = preload("res://Scenes/Enemies/Effects/Frog Tongue.tscn")
const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const NUMBER_OF_BULLETS = 5
const SPREAD = PI/6

var collision
var tongue
var fall_direction: Vector2

func _ready():
	super._ready()
	fall_direction = Vector2.DOWN.rotated($AnimatedSprite2D.rotation)

func _physics_process(delta):
	super._physics_process(delta)

func walk():
	var direction = global_position.direction_to(player.global_position).normalized()
	
	$AnimatedSprite2D.flip_h = direction.x < 0
	
	velocity.x = velocity.lerp(Vector2(sign(direction.x) * _enemy_stats.speed, 0), _enemy_stats.acceleration).x
	velocity.y = fall_direction.y * 1000
	
	move_and_slide()

func spawn_tongue():
	velocity = Vector2.ZERO
	tongue = FROG_TONGUE.instantiate()
	tongue.rotation = $AnimatedSprite2D.rotation
	tongue.direction = -fall_direction
	tongue.source = self
	tongue.visible = false
	add_child(tongue)
	tongue.position.y = $Down.position.y * -fall_direction.y
	launch_delay.start()

func launch():
	var launch_speed = _enemy_stats.speed * 25
	velocity = velocity.lerp(Vector2(0, launch_speed * -fall_direction.y), _enemy_stats.acceleration)
	
	collision = move_and_collide(velocity * get_physics_process_delta_time())
	
	if collision:
		if tongue and fall_direction.is_equal_approx(collision.get_normal()):
			tongue.queue_free()
			Targets.get_camera().add_trauma(0.25)
			for i in NUMBER_OF_BULLETS:
				var angle = SPREAD * (i + 1)
				var bullet = BULLET.instantiate()
				bullet.direction = Vector2.RIGHT.rotated(angle) * sign(fall_direction)
				bullet.range = 300
				bullet.speed = 450
				bullet.ignore_first_collision = true
				get_tree().current_scene.add_child(bullet)
				bullet.global_position = global_position
			_state_machine.set_state(_state_machine.states.crash)

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Tongue":
		spawn_tongue()
	if $AnimatedSprite2D.animation == "Tongue Crash":
		fall_direction = -fall_direction
		_state_machine.set_state(_state_machine.states.walk)

func _on_launch_delay_timeout():
	_state_machine.set_state(_state_machine.states.launch)

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "Tongue Crash":
		if $AnimatedSprite2D.frame == 2:
			$AnimatedSprite2D.rotation += clamp(0, PI, PI)
