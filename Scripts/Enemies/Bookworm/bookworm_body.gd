extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

var point: Vector2
var leading_segment
var direction: Vector2
var source
var MIN_DISTANCE

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	
	if not is_instance_valid(source):
		queue_free()
		return
	
	if global_position.distance_to(leading_segment.global_position) >= MIN_DISTANCE:
		direction = global_position.direction_to(leading_segment.global_position)
		velocity = direction * source._enemy_stats.speed
	elif global_position.distance_to(leading_segment.global_position) >= MIN_DISTANCE * 2:
		direction = global_position.direction_to(leading_segment.global_position)
		velocity = direction * source._enemy_stats.speed * 1.15
	else:
		velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	
	move_and_slide()
