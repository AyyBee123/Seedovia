extends "res://Scripts/Bosses/boss.gd"

## y = 37 when changed to wall
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var _state_machine = $StateMachine
@onready var splat_2_SFX = $Splat2
@onready var splat_SFX = $Splat
@onready var stomp_SFX = $Stomp

var _can_move: bool = false: set = set_move
var direction: Vector2

func _ready():
	super._ready()
	$Shadow.visible = false

func _physics_process(delta):
	super._physics_process(delta)

func idle():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	if player:
		direction = player.global_position - global_position

func jump():
	if _can_move:
		velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	else:
		velocity = Vector2.ZERO

func _on_animated_sprite_2d_frame_changed():
	pass
	#if $AnimatedSprite2D.animation == "Jump":
		#if animated_sprite_2d.frame == 1:
			#splat_2_SFX.play()
		#if animated_sprite_2d.frame == 5:
			#stomp_SFX.play()
			#splat_SFX.play()

func _on_animated_sprite_2d_animation_finished():
	pass
	#if animated_sprite_2d.animation == "Jump":
		#_state_machine.set_state(_state_machine.states.idle)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Jump":
		_state_machine.set_state(_state_machine.states.idle)

func set_move(value: bool):
	_can_move = value

func play_jump():
	splat_2_SFX.play()

func play_land():
	stomp_SFX.play()
	splat_SFX.play()
