extends "res://Scripts/Enemies/enemy.gd"

@onready var left_detect = $"Left Detect"
@onready var right_detect = $"Right Detect"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $StateMachine

var direction = 1
var forward_direction
var direction_changed := false


func _ready():
	super._ready()
	forward_direction = Vector2.RIGHT.rotated($AnimatedSprite2D.rotation)

func _physics_process(delta):
	super._physics_process(delta)

func move_forward():
	velocity = forward_direction * _enemy_stats.speed * direction
	if direction < 0:
		animated_sprite_2d.play_backwards("default")
	else:
		animated_sprite_2d.play("default")
	move_and_slide()

func _on_left_detect_body_entered(body):
	change_direction()

func _on_right_detect_body_entered(body):
	change_direction()

func change_direction():
	if _state_machine.state != _state_machine.states.forward:
		return
	direction = -direction
	_state_machine.set_state(_state_machine.states.idle)

func idle():
	velocity = Vector2.ZERO
	animated_sprite_2d.pause()
