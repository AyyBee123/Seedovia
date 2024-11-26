extends "res://Scripts/Enemies/enemy.gd"

@onready var iris = $Iris

var _y_dir: bool

func _ready():
	super._ready()
	_y_dir = false

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		follow_player_cardinally()

## set the enemy color to red for a brief time whne taking damage
func change_color():
	$AnimatedSprite2D.material.set("shader_parameter/tint_factor", 0.8)
	$Iris.material.set("shader_parameter/tint_factor", 0.8)
	await get_tree().create_timer(0.05, false).timeout
	$AnimatedSprite2D.material.set("shader_parameter/tint_factor", 0.0)
	$Iris.material.set("shader_parameter/tint_factor", 0.0)

func follow_player_cardinally():
	var distance_x = player.global_position.x - global_position.x
	var distance_y = player.global_position.y - global_position.y
	
	if abs(distance_y) <= 30:
		_y_dir = false
	if abs(distance_x) <= 20:
		_y_dir = true
	
	if _y_dir:
		velocity = velocity.lerp(Vector2(0, sign(distance_y) * _enemy_stats.speed), _enemy_stats.acceleration)
		iris.position = Vector2(0, sign(distance_y) * 5 - 5)
	else:
		velocity = velocity.lerp(Vector2(sign(distance_x) * _enemy_stats.speed, 0), _enemy_stats.acceleration)
		iris.position = Vector2(sign(distance_x) * 5, -5)
	move_and_slide()
