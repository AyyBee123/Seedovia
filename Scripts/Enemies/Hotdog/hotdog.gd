extends "res://Scripts/Enemies/enemy.gd"

@onready var hotdog_sprite = %HotdogSprite
@onready var left = %Left
@onready var right = %Right
@onready var hotdog_collision = %CollisionShape2D
@onready var spin_time = $"Spin Time"
@onready var deceleration = $"Spin Deceleration"
@onready var acceleration = $"Spin Acceleration"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var stretch_SFX = $Stretch

const SPIN_SPEED = 1.5
const MAX_LENGTH = 10

var tween

func _physics_process(delta):
	super._physics_process(delta)
	# set sizes and positions in real-time to match the hotdog length
	var length = 27 + hotdog_sprite.get_region_rect().size.x / 2 * (hotdog_sprite.scale.x - 1)
	left.position.x = -length
	right.position.x = length
	hotdog_collision.shape.size.x = 12 + hotdog_sprite.scale.x * 46

func idle():
	# slow the hotdog rotation down to a stop
	animated_sprite_2d.rotation += get_physics_process_delta_time() \
			* deceleration.time_left / deceleration.wait_time * SPIN_SPEED
	hotdog_sprite.rotation = animated_sprite_2d.rotation
	
	velocity = velocity.lerp(Vector2.ZERO * _enemy_stats.speed, _enemy_stats.friction)
	
	move_and_slide()

func spin():
	# rotate the hotdog
	animated_sprite_2d.rotation += get_physics_process_delta_time() \
			* SPIN_SPEED * (1 - (acceleration.time_left / acceleration.wait_time))
	hotdog_sprite.rotation = animated_sprite_2d.rotation
	
	if player:
		velocity = velocity.lerp(global_position.direction_to(player.global_position) * _enemy_stats.speed, \
				_enemy_stats.acceleration)
	
	move_and_slide()

func stretch():
	# stretch the hotdog
	stretch_SFX.play()
	tween = get_tree().create_tween()
	tween.tween_property(hotdog_sprite, "scale:x", MAX_LENGTH, 1)

func shrink():
	# shrink the hotdog
	tween = get_tree().create_tween()
	tween.tween_property(hotdog_sprite, "scale:x", 1, 0.5)

func _on_hotdog_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player = body # just in case
		is_in_area = true

func _on_hotdog_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func _exit_tree():
	if tween:
		tween.kill()
