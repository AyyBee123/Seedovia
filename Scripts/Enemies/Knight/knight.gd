extends "res://Scripts/Enemies/enemy.gd"

@onready var shadow = $Shadow
@onready var jump_SFX = $Jump
@onready var stomp_SFX = $Stomp
@onready var idle_time = $"Idle Time"
@onready var animation_player = $AnimationPlayer

const SPREAD = PI/4

var IDLE_TIME: float
var direction: Vector2
var move_direction: Vector2
var angles: Array
var tween
var next_pos

func _ready():
	super._ready()
	$"Enemy Hitbox/CollisionPolygon2D".disabled = false
	
	for i in TAU / SPREAD:
		var angle = SPREAD * i
		if angle < 0:
			angle += TAU
		angles.append(angle)
	
	IDLE_TIME = idle_time.wait_time
	randomize()
	shadow.visible = false
	idle_time.start(randf_range(1, 2))
	# snap the position initially, just in case
	global_position = snapped(global_position, Vector2(128, 128)) - Vector2(64, 64)

func _physics_process(delta):
	super._physics_process(delta)
	
	direction = global_position.direction_to(player.global_position)
	var angle = direction.angle()
	# makes the angle rotation go from 0 to 360, instead of 0 to 180 and then -180 to 0
	if angle < 0:
		angle += TAU
	
	if angle >= angles[1] and angle < angles[2]:
		move_direction = Vector2(1, 2)
	elif angle >= angles[2] and angle < angles[3]:
		move_direction = Vector2(-1, 2)
	elif angle >= angles[3] and angle < angles[4]:
		move_direction = Vector2(-2, 1)
	elif angle >= angles[4] and angle < angles[5]:
		move_direction = Vector2(-2, -1)
	elif angle >= angles[5] and angle < angles[6]:
		move_direction = Vector2(-1, -2)
	elif angle >= angles[6] and angle < angles[7]:
		move_direction = Vector2(1, -2)
	elif angle >= angles[7] and angle < angles[0] + TAU:
		move_direction = Vector2(2, -1)
	else:
		move_direction = Vector2(2, 1)

func play_jump():
	jump_SFX.play()

func play_stomp():
	stomp_SFX.play()
	idle_time.start(IDLE_TIME)

func _on_idle_time_timeout():
	animation_player.play("Knight/Jump")

func _on_animation_player_animation_started(anim_name):
	# edge cases to avoid walls
	# bottom-right corner
	if (global_position.y > 150 and move_direction.y > 0) and (global_position.x > 550 and move_direction.x > 0):
		if move_direction.x == 2:
			if global_position.x > 650:
				move_direction = Vector2(-1, -2)
			else:
				move_direction = Vector2(1, -2)
		elif move_direction.y == 2:
			if global_position.y > 300:
				move_direction = Vector2(-2, -1)
			else:
				move_direction = Vector2(-2, 1)
	# bottom-left corner
	elif (global_position.y > 150 and move_direction.y > 0) and (global_position.x < -550 and move_direction.x < 0):
		if move_direction.x == -2:
			if global_position.x < -650:
				move_direction = Vector2(1, -2)
			else:
				move_direction = Vector2(-1, -2)
		elif move_direction.y == 2:
			if global_position.y > 300:
				move_direction = Vector2(2, -1)
			else:
				move_direction = Vector2(2, 1)
	# top-right corner
	elif (global_position.y < -150 and move_direction.y < 0) and (global_position.x > 550 and move_direction.x > 0):
		if move_direction.x == 2:
			if global_position.x > 650:
				move_direction = Vector2(-1, 2)
			else:
				move_direction = Vector2(1, 2)
		elif move_direction.y == -2:
			if global_position.y < -300:
				move_direction = Vector2(-2, 1)
			else:
				move_direction = Vector2(-2, -1)
	# top-left corner
	elif (global_position.y < -150 and move_direction.y < 0) and (global_position.x < -550 and move_direction.x < 0):
		if move_direction.x == -2:
			if global_position.x < -650:
				move_direction = Vector2(1, 2)
			else:
				move_direction = Vector2(-1, 2)
		elif move_direction.y == -2:
			if global_position.y < -300:
				move_direction = Vector2(2, 1)
			else:
				move_direction = Vector2(2, -1)
	# bottom edge
	elif global_position.y > 150 and move_direction.y == 2:
		if move_direction == Vector2(1, 2):
			if global_position.y > 300:
				move_direction = Vector2(2, -1)
			else:
				move_direction = Vector2(2, 1)
		else:
			if global_position.y > 300:
				move_direction = Vector2(-2, -1)
			else:
				move_direction = Vector2(-2, 1)
	# top edge
	elif global_position.y < -150 and move_direction.y == -2:
		if move_direction == Vector2(1, -2):
			if global_position.y < -300:
				move_direction = Vector2(2, 1)
			else:
				move_direction = Vector2(2, -1)
		else:
			if global_position.y < -300:
				move_direction = Vector2(-2 , 1)
			else:
				move_direction = Vector2(-2, -1)
	# right edge
	elif global_position.x > 550 and move_direction.x == 2:
		if move_direction == Vector2(2, 1):
			if global_position.x > 650:
				move_direction = Vector2(-1, 2)
			else:
				move_direction = Vector2(1, 2)
		else:
			if global_position.x > 650:
				move_direction = Vector2(-1, -2)
			else:
				move_direction = Vector2(1, -2)
	# left edge
	elif global_position.x < -550 and move_direction.x == -2:
		if move_direction == Vector2(-2, 1):
			if global_position.x < -650:
				move_direction = Vector2(1, -2)
			else:
				move_direction = Vector2(-1, 2)
		else:
			if global_position.x < -650:
				move_direction = Vector2(1, -2)
			else:
				move_direction = Vector2(-1, -2)
	# "touching" the y-axis edges
	elif (global_position.y > 300 and move_direction.y > 0) or (global_position.y < -300 and move_direction.y < 0):
		move_direction.y *= -1
	# "touching" the x-axis edges
	elif (global_position.x > 650 and move_direction.x > 0) or (global_position.x < -650 and move_direction.x < 0):
		move_direction.x *= -1
	
	# snap the end position to land on a "grid"
	var new_pos = snapped(Vector2(128, 128) * move_direction, Vector2(128, 128))
	var anim_speed = animation_player.get_animation(anim_name).get_length() / animation_player.speed_scale
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_pos, anim_speed).as_relative()
	tween.tween_callback(func(): global_position = snapped(global_position, Vector2(128, 128)) - Vector2(64, 64))
