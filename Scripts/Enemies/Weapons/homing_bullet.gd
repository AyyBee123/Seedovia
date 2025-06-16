extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var homing_timer = $"Homing Timer"
@onready var pointer = %Pointer
@onready var marker_2d = %Marker2D
@onready var homing_delay = $"Homing Delay"

var home_time: float
var homing: bool = false
var rotation_speed: float

func _ready():
	super._ready()
	pointer.rotation = direction.angle()
	if home_time > 0:
		homing_timer.wait_time = home_time

func _physics_process(delta):
	super._physics_process(delta)
	
	player = Targets.get_player()

func update_position(delta):
	if homing and player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed * delta)
	var current_velocity = global_position.direction_to(marker_2d.global_position) * speed
	position += current_velocity * delta

func _on_homing_timer_timeout():
	homing = false

func _on_homing_delay_timeout():
	homing = true
	homing_timer.start()
