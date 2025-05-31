extends "res://Scripts/Enemies/enemy.gd"

@onready var down = $"Player Detect/Down"
@onready var up = $"Player Detect/Up"
@onready var left = $"Player Detect/Left"
@onready var right = $"Player Detect/Right"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $state_machine
@onready var area_detect = $"Player Detect".get_overlapping_bodies()
@onready var burp_SFX = $Burp
@onready var jump_SFX = $Jump

const FAT_POT_BALL = preload("res://Scenes/Enemies/Weapons/Fat Pot Ball.tscn")

const SPREAD = PI/2

var angles: Array
var direction: Vector2
var look_direction: Vector2

## for idle animation when switching directions mid-animation
var current_frame = 0
var current_progress = 0

func _ready():
	super._ready()
	
	for i in TAU / SPREAD:
		var angle = SPREAD * i - SPREAD / 2
		if angle < 0:
			angle += TAU
		angles.append(angle)

func _physics_process(delta):
	super._physics_process(delta)
	direction = global_position.direction_to(player.global_position)

func idle():
	var angle = direction.angle()
	# makes the angle rotation go from 0 to 360, instead of 0 to 180 and then -180 to 0
	if angle < 0:
		angle += TAU
	
	if angle >= angles[1] and angle < angles[2]:
		look_direction = Vector2.DOWN
		animated_sprite_2d.play("Idle Front")
	elif angle >= angles[2] and angle < angles[3]:
		look_direction = Vector2.LEFT
		animated_sprite_2d.play("Idle Side")
	elif angle >= angles[3] and angle < angles[0]:
		look_direction = Vector2.UP
		animated_sprite_2d.play("Idle Back")
	else:
		look_direction = Vector2.RIGHT
		animated_sprite_2d.play("Idle Side")
	
	current_frame = animated_sprite_2d.get_frame()
	current_progress = animated_sprite_2d.get_frame_progress()
	animated_sprite_2d.set_frame_and_progress(current_frame, current_progress)
	
	down.disabled = not look_direction == Vector2.DOWN
	up.disabled = not look_direction == Vector2.UP
	left.disabled = not look_direction == Vector2.LEFT
	right.disabled = not look_direction == Vector2.RIGHT
	
	animated_sprite_2d.flip_h = look_direction == Vector2.LEFT
	
	area_detect = $"Player Detect".get_overlapping_bodies()

func charge():
	match look_direction:
		Vector2.DOWN:
			animated_sprite_2d.play("Charge Front")
		Vector2.UP:
			animated_sprite_2d.play("Charge Back")
		Vector2.RIGHT:
			animated_sprite_2d.play("Charge Side")
		Vector2.LEFT:
			animated_sprite_2d.play("Charge Side")

func shoot():
	jump_SFX.play()
	burp_SFX.play()
	
	match look_direction:
		Vector2.DOWN:
			animated_sprite_2d.play("Shoot Front")
		Vector2.UP:
			animated_sprite_2d.play("Shoot Back")
		Vector2.RIGHT:
			animated_sprite_2d.play("Shoot Side")
		Vector2.LEFT:
			animated_sprite_2d.play("Shoot Side")
	
	var NUMBER_OF_BALLS = randi_range(30, 40)
	
	for i in NUMBER_OF_BALLS:
		var ball = FAT_POT_BALL.instantiate()
		ball.direction = look_direction
		ball.damage = _enemy_stats.weapon_damage
		ball.range = _enemy_stats.weapon_range
		ball.speed = _enemy_stats.weapon_speed * (i + 1) + randf_range(-75, 75)
		ball.z_index = z_index - 1
		if look_direction == Vector2.DOWN:
			ball.z_index = z_index
		get_tree().current_scene.add_child(ball)
		ball.global_position = global_position + look_direction.rotated(PI/2) * randf_range(-25, 25)
