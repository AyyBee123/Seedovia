extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var return_delay = $"Return Delay"
@onready var acceleration = $Acceleration

var returning: bool
var source

func _ready():
	super._ready()
	return_delay.wait_time = 0.5
	acceleration.start(1.8)

func _physics_process(delta):
	super._physics_process(delta)
	if not is_instance_valid(source):
		queue_free()

func travelled_distance():
	pass

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
	if body.is_in_group("Enemies") and body.get_parent() == source and returning:
		queue_free()

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	if not return_delay.is_stopped():
		return
	if not returning:
		position += current_velocity * delta * acceleration.time_left / acceleration.wait_time
	else:
		direction = global_position.direction_to(source.global_position).normalized()
		current_velocity = direction * speed
		position += current_velocity * delta * (1 - acceleration.time_left / acceleration.wait_time)

func _on_acceleration_timeout():
	if returning:
		return
	return_delay.start()
	returning = true

func _on_return_delay_timeout():
	acceleration.start(0.5)

func _exit_tree():
	if source:
		Game.audio_manager.play(Game.audio_manager.cake_return)
		source.number_of_slices += 1
