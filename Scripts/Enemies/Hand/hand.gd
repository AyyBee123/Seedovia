extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $StateMachine
@onready var animation_player = $AnimationPlayer
@onready var jump_SFX = $Jump
@onready var stomp_SFX = $Stomp

var t_slam = 0.0
var t_idle = 0.0
var in_pos: bool

# variables for charge state
var side_index: int = -1
var charge_area_range: Vector2
var charge_area_direction: Vector2
var ready_to_charge: bool

# vairables for hats state
var off_screen: bool

var charge_pos: Vector2

func _ready():
	super._ready()
	player = Targets.get_player()
	$"Enemy Hitbox/CollisionPolygon2D".disabled = true

func _physics_process(delta):
	super._physics_process(delta)

func idle():
	if player:
		velocity = global_position.direction_to(player.global_position) * _enemy_stats.speed

func slam():
	velocity = Vector2.ZERO
	t_slam = min(t_slam + get_physics_process_delta_time() * 0.5, 1)
	if in_pos:
		global_position = lerp(global_position, \
				Vector2(player.global_position.x, player.global_position.y - $Shadow.position.y * scale.y + 4), t_slam)

func slam_start():
	in_pos = true
	var tween = get_tree().create_tween()
	tween.tween_callback(slam_attack).set_delay(2)

func slam_attack():
	in_pos = false
	animated_sprite_2d.stop()
	animation_player.play("new_animation")

func _on_animation_player_animation_finished(anim_name):
	_state_machine.set_state(_state_machine.states.idle)

func play_jump():
	jump_SFX.play()

func play_stomp():
	stomp_SFX.play()
