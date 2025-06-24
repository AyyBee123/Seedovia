extends "res://Scripts/Enemies/enemy.gd"

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var splat_3 = $Splat2
@onready var splat_2 = $Splat
@onready var stomp = $Stomp
@onready var _state_machine = $state_machine

const BIG_GOOP = preload("res://Scenes/Misc/Big Goop.tscn")

var _can_move: bool = false: set = set_move
var direction: Vector2
var _jumping: bool

func _ready():
	super._ready()
	$Shadow.visible = false

func _physics_process(delta):
	visible = true
	super._physics_process(delta)

func jump():
	if _can_move:
		velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	else:
		velocity = Vector2.ZERO

func idle():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	if player:
		direction = player.global_position - global_position

func set_move(value: bool):
	_can_move = value

func play_splat_2():
	splat_2.play()
	stomp.play()

func play_splat_3():
	splat_3.play()

func jump_finished():
	_jumping = false

func goop():
	Targets.get_camera().add_trauma(0.25)
	var goop = BIG_GOOP.instantiate()
	get_tree().current_scene.add_child(goop)
	goop.global_position = global_position
