extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite = $AnimatedSprite2D
@onready var pointer = $Pointer
@onready var marker_2d = $Pointer/Marker2D

const VENOM = preload("res://Scenes/Misc/Venom.tscn")
const RANGE = 60
const ROTATION_SPEED = 6
const SPREAD = PI/2

var direction: Vector2
var distance_travelled = 0
var total_distance = 0
var starting_position
var angles: Array

func _ready():
	super._ready()
	for i in TAU / SPREAD:
		var angle = SPREAD * i - SPREAD / 2
		if angle < 0:
			angle += TAU
		angles.append(angle)
	
	starting_position = global_position
	
	# look at the player's spawn point at the start to avoid turning when entering a new room
	pointer.rotation = global_position.direction_to(Vector2(0, 330)).angle()

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), ROTATION_SPEED * delta)
		velocity = velocity.lerp(global_position.direction_to(marker_2d.global_position) * _enemy_stats.speed, \
				_enemy_stats.acceleration)
	
	var angle = direction.angle()
	# makes the angle rotation go from 0 to 360, instead of 0 to 180 and then -180 to 0
	if angle < 0:
		angle += TAU
	
	# get angle between player and self to determine the animation being played
	var current_frame = animated_sprite.get_frame()
	var current_progress = animated_sprite.get_frame_progress()
	if angle >= angles[1] and angle < angles[2]:
		animated_sprite.play("Front")
	elif angle >= angles[2] and angle < angles[3]:
		animated_sprite.play("Left")
	elif angle >= angles[3] and angle < angles[0]:
		animated_sprite.play_backwards("Front")
	else:
		animated_sprite.play_backwards("Left")
	animated_sprite.set_frame_and_progress(current_frame, current_progress)

	
	move_and_slide()
	travelled_distance()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		total_distance = 0
		var venom = VENOM.instantiate()
		get_tree().current_scene.add_child(venom)
		venom.global_position = global_position
