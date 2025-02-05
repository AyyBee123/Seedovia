extends "res://Scripts/Enemies/enemy.gd"

@onready var pointer = $Pointer
@onready var marker_2d = $Pointer/Marker2D

var direction: Vector2
var rotation_speed: float

func _ready():
	super._ready()
	randomize()
	rotation_speed = randf_range(1, 8)
	
	# look at the player's spawn point at the start to avoid turning when entering a new room
	pointer.rotation = global_position.direction_to(Vector2(0, 330)).angle()

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed * delta)
		velocity = global_position.direction_to(marker_2d.global_position) * _enemy_stats.speed
	
	move_and_slide()
