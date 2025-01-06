extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $StateMachine
@onready var animation_player = $AnimationPlayer

var mad_hat
var pos
var in_pos: bool
var t_slam = 0.0
var t_idle = 0.0
var other_hand

func _ready():
	super._ready()
	player = Targets.get_player()
	$Hitbox/CollisionShape2D.disabled = true
	global_position = pos + mad_hat.animated_sprite_2d.global_position
	await get_tree().physics_frame # wait for the second hand to spawn (which happens after one more frame)
	for i in get_tree().get_nodes_in_group("Mad Hat Hand"):
		if i != self:
			other_hand = i
			print(i.name)
			break

func _physics_process(delta):
	super._physics_process(delta)

func idle():
	t_idle += get_physics_process_delta_time() * 0.5
	global_position = lerp(global_position, pos + mad_hat.animated_sprite_2d.global_position, t_idle)
	if mad_hat._state_machine.state == mad_hat._state_machine.states.idle:
		animated_sprite_2d.stop()
		animated_sprite_2d.frame = mad_hat.animated_sprite_2d.frame
	else:
		if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation != "Idle":
			animated_sprite_2d.play("Idle")

func slam():
	t_slam += get_physics_process_delta_time() * 0.5
	if in_pos:
		global_position = lerp(global_position, \
				Vector2(player.global_position.x, player.global_position.y - $Shadow.position.y * scale.y + 4), t_slam)

func handpocalypse():
	pass

func charge():
	pass

func slam_start():
	in_pos = true
	var tween = get_tree().create_tween()
	tween.tween_callback(slam_attack).set_delay(2)

func slam_attack():
	in_pos = false
	animated_sprite_2d.play("Slam")
	animation_player.play("new_animation")

func _on_animation_player_animation_finished(anim_name):
	_state_machine.set_state(_state_machine.states.idle)
