extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D

var point: Vector2
var leading_segment
var direction: Vector2
var source
var MIN_DISTANCE

func _ready():
	super._ready()
	_enemy_stats.spawn_damage_number.connect(transfer_damage)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.change_color.connect(change_color)

func _physics_process(delta):
	super._physics_process(delta)
	
	if not is_instance_valid(source):
		queue_free()
		return
	
	if global_position.distance_to(leading_segment.global_position) >= MIN_DISTANCE:
		direction = global_position.direction_to(leading_segment.global_position)
		velocity = direction * source._enemy_stats.speed * source.speed_multi
	elif global_position.distance_to(leading_segment.global_position) >= MIN_DISTANCE * 1.05:
		direction = global_position.direction_to(leading_segment.global_position)
		velocity = direction * source._enemy_stats.speed * source.speed_multi * 10
	else:
		velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	
	move_and_slide()

func transfer_damage(amount):
	if not is_instance_valid(source):
		return
	source._enemy_stats.take_damage_no_red(amount * 0.5)

func update_health(new_health):
	_enemy_stats.set_health(_enemy_stats.max_health)

func change_color():
	animated_sprite_2d.material.set("shader_parameter/tint_factor", 0.8)
	await get_tree().create_timer(0.05, false).timeout
	animated_sprite_2d.material.set("shader_parameter/tint_factor", 0.0)
