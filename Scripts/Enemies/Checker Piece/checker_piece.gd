extends "res://Scripts/Enemies/enemy.gd"

@onready var shadow = $Shadow
@onready var idle_time = $"Idle Time"
@onready var animation_player = $AnimationPlayer

const SPREAD = PI/2

var IDLE_TIME: float
var direction: Vector2
var move_direction: Vector2
var angles: Array
var tween
var next_pos
var path_to_player: Array

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
	idle_time.start(randf_range(0.25, 0.5))
	 # snap the position initially, just in case
	global_position = snapped(global_position, Vector2(128, 128)) - Vector2(64, 64)

func _physics_process(delta):
	super._physics_process(delta)
	
	if player == null: # keep looking for the player until they are found
		return
	direction = global_position.direction_to(player.global_position)
	var angle = direction.angle()
	# makes the angle rotation go from 0 to 360, instead of 0 to 180 and then -180 to 0
	if angle < 0:
		angle += TAU
	
	if angle >= angles[1] and angle < angles[2]:
		move_direction = Vector2(-1, 1)
	elif angle >= angles[2] and angle < angles[3]:
		move_direction = Vector2(-1, -1)
	elif angle >= angles[3] and angle < angles[0] + TAU:
		move_direction = Vector2(1, -1)
	else:
		move_direction = Vector2(1, 1)

func play_stomp():
	Game.audio_manager.play(Game.audio_manager.chip)
	idle_time.start(IDLE_TIME)

func _on_idle_time_timeout():
	animation_player.play("Checker/Jump")

func _on_animation_player_animation_started(anim_name):
	# edge cases to avoid walls
	# "touching" the y-axis edges
	if (global_position.y > 300 and move_direction.y > 0) or (global_position.y < -300 and move_direction.y < 0):
		move_direction.y *= -1
	# "touching" the x-axis edges
	if (global_position.x > 650 and move_direction.x > 0) or (global_position.x < -650 and move_direction.x < 0):
		move_direction.x *= -1
	
	# snap the end position to land on a "grid"
	var new_pos = snapped(Vector2(128, 128) * move_direction, Vector2(128, 128))
	var anim_speed = animation_player.get_animation(anim_name).get_length() / animation_player.speed_scale
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_pos, anim_speed).as_relative()
	tween.tween_callback(func(): global_position = snapped(global_position, Vector2(128, 128)) - Vector2(64, 64))
