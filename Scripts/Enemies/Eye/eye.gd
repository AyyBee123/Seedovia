extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shoot_time = $"Shoot Time"
@onready var bubble_pop_SFX = $BubblePop

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const SPREAD = PI/4

var angles: Array
var direction: Vector2

func _ready():
	super._ready()
	for i in 8:
		var angle = SPREAD * i - SPREAD / 2
		if angle < 0:
			angle += TAU
		angles.append(angle)

func _physics_process(delta):
	super._physics_process(delta)

func idle():
	direction = global_position.direction_to(player.global_position)
	var angle = direction.angle()
	# makes the angle rotation go from 0 to 360, instead of 0 to 180 and then -180 to 0
	if angle < 0:
		angle += TAU
	
	var current_frame = animated_sprite_2d.get_frame()
	var current_progress = animated_sprite_2d.get_frame_progress()
	
	# make the eye look at the player, based on the angle between them
	if angle >= angles[1] and angle < angles[2]:
		animated_sprite_2d.play("Down-Right")
	elif angle >= angles[2] and angle < angles[3]:
		animated_sprite_2d.play("Down")
	elif angle >= angles[3] and angle < angles[4]:
		animated_sprite_2d.play("Down-Left")
	elif angle >= angles[4] and angle < angles[5]:
		animated_sprite_2d.play("Left")
	elif angle >= angles[5] and angle < angles[6]:
		animated_sprite_2d.play("Up-Left")
	elif angle >= angles[6] and angle < angles[7]:
		animated_sprite_2d.play("Up")
	elif angle >= angles[7] and angle < angles[0]:
		animated_sprite_2d.play("Up-Right")
	else:
		animated_sprite_2d.play("Right")
	
	animated_sprite_2d.set_frame_and_progress(current_frame, current_progress)
	
	velocity = velocity.lerp(_enemy_stats.speed * direction, _enemy_stats.friction)
	move_and_slide()

func shoot():
	velocity = velocity.lerp(_enemy_stats.speed * direction * 15, _enemy_stats.acceleration)
	move_and_slide()

func end_shoot():
	velocity = velocity.lerp(_enemy_stats.speed * direction, _enemy_stats.friction)
	move_and_slide()

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "Shoot":
		var bullet = BULLET.instantiate()
		var dir: Vector2
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed
		match animated_sprite_2d.frame:
			0:
				dir = Vector2(0, 1)
			1:
				dir = Vector2(-1, 1)
			2:
				dir = Vector2(-1, 0)
			3:
				dir = Vector2(-1, -1)
			4:
				dir = Vector2(0, -1)
			5:
				dir = Vector2(1, -1)
			6:
				dir = Vector2(1, 0)
			7:
				dir = Vector2(1, 1)
		bullet.direction = dir.normalized()
		bubble_pop_SFX.play()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + bullet.direction * 20
