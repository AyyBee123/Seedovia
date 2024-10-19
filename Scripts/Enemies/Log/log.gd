extends "res://Scripts/Enemies/enemy.gd"

@onready var left_detect = $"Left Detect"
@onready var right_detect = $"Right Detect"
@onready var right_direction_point = $"Right Direction Point"
@onready var animated_sprite_2d = $AnimatedSprite2D

var forward_direction
var direction = 1
var direction_changed := false

func _ready():
	super._ready()
	# check the initial x-position of the log to determine horizontal direction
	if global_position.x > 0:
		direction = -1
	else:
		direction = 1

func _physics_process(delta):
	super._physics_process(delta)

func move_forward():
	forward_direction = global_position.direction_to(right_direction_point.global_position).normalized()
	velocity = velocity.lerp(forward_direction * _enemy_stats.speed * direction, _enemy_stats.acceleration)
	if direction < 0:
		animated_sprite_2d.play("default")
	else:
		animated_sprite_2d.play_backwards("default")

func _on_left_detect_body_entered(body):
	change_direction()

func _on_right_detect_body_entered(body):
	change_direction()

func change_direction():
	direction_changed = true
	direction = -direction

func idle():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	animated_sprite_2d.pause()
