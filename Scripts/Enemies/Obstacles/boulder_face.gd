extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@export_enum("Bottom Right", "Bottom Left", "Top Right", "Top Left") var starting_direction = 0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var rock_2 = $Rock2
@onready var stomp = $Stomp

var collision
var direction

func _ready():
	super._ready()
	
	match starting_direction:
		0:
			direction = Vector2(1, 1)
		1:
			direction = Vector2(-1, 1)
		2:
			direction = Vector2(1, -1)
		3:
			direction = Vector2(-1, -1)
	
	change_anim()

func _physics_process(delta):
	super._physics_process(delta)
	velocity = velocity.lerp(_enemy_stats.speed * direction.normalized(), _enemy_stats.acceleration)
	collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		direction = velocity
		Targets.get_camera().add_trauma(0.2)
		rock_2.play()
		stomp.play()
		change_anim()

func change_anim():
	var current_frame = animated_sprite_2d.get_frame()
	var current_progress = animated_sprite_2d.get_frame_progress()
	if direction.x > 0 and direction.y > 0:
		animated_sprite_2d.play("Bottom-Right")
	elif direction.x < 0 and direction.y > 0:
		animated_sprite_2d.play("Bottom-Left")
	elif direction.x > 0 and direction.y < 0:
		animated_sprite_2d.play("Top-Right")
	else:
		animated_sprite_2d.play("Top-Left")
	animated_sprite_2d.set_frame_and_progress(current_frame, current_progress)
