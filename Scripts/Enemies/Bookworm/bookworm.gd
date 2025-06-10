extends "res://Scripts/Enemies/enemy.gd"

const BOOKWORM_BODY = preload("res://Scenes/Enemies/Bookworm Body.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var pointer = $Pointer
@onready var marker_2d = $Pointer/Marker2D

const SPREAD = PI/4
const MIN_DISTANCE = 24
const NUMBER_OF_SEGMENTS = 12

var direction: Vector2
var angles: Array
var rotation_speed: float = 2
var segments: Array
var leading_segment
var size = 1

func _ready():
	super._ready()
	
	for i in NUMBER_OF_SEGMENTS:
		var segment = BOOKWORM_BODY.instantiate()
		segment.source = self
		segment.direction = direction
		# assign the leading segment for each segment to directly follow
		if leading_segment:
			segment.leading_segment = segments[i - 1]
		else:
			segment.leading_segment = self
		size -= 0.05
		segment.scale = scale * size
		get_tree().current_scene.add_child.call_deferred(segment)
		segment.global_position = global_position
		segments.append(segment)
		leading_segment = segment
	
	for i in TAU / SPREAD:
		var angle = SPREAD * i - SPREAD / 2
		if angle < 0:
			angle += TAU
		angles.append(angle)
	
	# look at the player's spawn point at the start to avoid turning when entering a new room
	pointer.rotation = global_position.direction_to(Vector2(0, 330)).angle()

func _physics_process(delta):
	super._physics_process(delta)
	
	var angle = global_position.direction_to(marker_2d.global_position).angle()
	# makes the angle rotation go from 0 to 360, instead of 0 to 180 and then -180 to 0
	if angle < 0:
		angle += TAU
	
	var current_frame = animated_sprite_2d.get_frame()
	var current_progress = animated_sprite_2d.get_frame_progress()
	
	# make the eye look at the player, based on the angle between them
	if angle >= angles[1] and angle < angles[2]:
		animated_sprite_2d.play("Down-Right")
	elif angle >= angles[2] and angle < angles[3]:
		animated_sprite_2d.play("Down")
	elif angle >= angles[3] and angle < angles[4]:
		animated_sprite_2d.play("Down-Left")
	elif angle >= angles[4] and angle < angles[5]:
		animated_sprite_2d.play("Left")
	elif angle >= angles[5] and angle < angles[6]:
		animated_sprite_2d.play("Up-Left")
	elif angle >= angles[6] and angle < angles[7]:
		animated_sprite_2d.play("Up")
	elif angle >= angles[7] and angle < angles[0]:
		animated_sprite_2d.play("Up-Right")
	else:
		animated_sprite_2d.play("Right")
	
	animated_sprite_2d.set_frame_and_progress(current_frame, current_progress)
	
	if player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed * delta)
		velocity = global_position.direction_to(marker_2d.global_position) * _enemy_stats.speed
	
	move_and_slide()
