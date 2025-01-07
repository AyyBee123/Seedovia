extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $StateMachine
@onready var animation_player = $AnimationPlayer

const RIGHT_HAND = preload("res://Scenes/Enemies/Weapons/Right Hand.tscn")
const LEFT_HAND = preload("res://Scenes/Enemies/Weapons/Left Hand.tscn")
const DOWN_HAND = preload("res://Scenes/Enemies/Weapons/Down Hand.tscn")
const UP_HAND = preload("res://Scenes/Enemies/Weapons/Up Hand.tscn")

var mad_hat
var pos
var in_pos: bool
var t_slam = 0.0
var t_idle = 0.0
var other_hand
var side_index: int = -1
var charge_area_range: Vector2
var charge_area_direction: Vector2
var ready_to_charge: bool
var charge_pos: Vector2

func _ready():
	super._ready()
	player = Targets.get_player()
	$Hitbox/CollisionShape2D.disabled = true
	global_position = pos + mad_hat.animated_sprite_2d.global_position
	await get_tree().physics_frame # wait for the second hand to spawn (which happens after one more frame)
	for i in get_tree().get_nodes_in_group("Mad Hat Hand"):
		if i != self:
			other_hand = i
			break

func _physics_process(delta):
	super._physics_process(delta)

func idle():
	t_idle = min(t_idle + get_physics_process_delta_time() * 0.5, 1)
	global_position = lerp(global_position, pos + mad_hat.animated_sprite_2d.global_position, t_idle)
	if mad_hat._state_machine.state == mad_hat._state_machine.states.idle:
		animated_sprite_2d.stop()
		animated_sprite_2d.frame = mad_hat.animated_sprite_2d.frame
	else:
		if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation != "Idle":
			animated_sprite_2d.play("Idle")

func slam():
	t_slam = min(t_slam + get_physics_process_delta_time() * 0.5, 1)
	if in_pos:
		global_position = lerp(global_position, \
				Vector2(player.global_position.x, player.global_position.y - $Shadow.position.y * scale.y + 4),t_slam)

func handpocalypse():
	pass

func charge():
	if side_index < 0:
		return
	if not ready_to_charge:
		velocity = velocity.lerp(charge_pos.normalized() * 500, _enemy_stats.acceleration)

func set_side():
	ready_to_charge = false
	side_index = randi_range(0, 3) # 0 = UP, 1 = DOWN, 2 = LEFT, 3 = RIGHT
	match side_index:
		0: # DOWN TO UP
			charge_area_range = Vector2(-768, 768)
			charge_area_direction = Vector2(0, 1)
		1: # UP TO DOWN
			charge_area_range = Vector2(-768, 768)
			charge_area_direction = Vector2(0, -1)
		2: # RIGHT TO LEFT
			charge_area_range = Vector2(-384, 384)
			charge_area_direction = Vector2(1, 0)
		3: # LEFT TO RIGHT
			charge_area_range = Vector2(-384, 384)
			charge_area_direction = Vector2(-1, 0)
	# WTF?
	charge_pos = randf_range(charge_area_range.x, charge_area_range.y) \
			* Vector2(abs(charge_area_direction.y), abs(charge_area_direction.x)) + charge_area_direction \
			* Vector2(1115, 735)

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

func _on_visible_on_screen_notifier_2d_screen_exited():
	if _state_machine.state != _state_machine.states.charge:
		return
	ready_to_charge = true
	
	var charging_hand
	match side_index:
		0:
			charging_hand = UP_HAND.instantiate()
		1:
			charging_hand = DOWN_HAND.instantiate()
		2:
			charging_hand = LEFT_HAND.instantiate()
		3:
			charging_hand = RIGHT_HAND.instantiate()
	charging_hand.hand = self
	await get_tree().create_timer(1).timeout
	get_tree().current_scene.add_child(charging_hand)
	charging_hand.global_position = charge_pos
