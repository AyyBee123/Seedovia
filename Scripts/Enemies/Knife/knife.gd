extends "res://Scripts/Enemies/enemy.gd"

@onready var collision_polygon_2d = $"Enemy Hitbox/CollisionPolygon2D"
@onready var collision_polygon_2d_2 = $CollisionPolygon2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var decel = $Deceleration
@onready var _state_machine = $state_machine

var tween
var direction: Vector2

func _physics_process(delta):
	super._physics_process(delta)
	collision_polygon_2d.rotation = animated_sprite_2d.rotation
	collision_polygon_2d_2.rotation = animated_sprite_2d.rotation

func dash():
	velocity = velocity.lerp(_enemy_stats.speed * direction.normalized() * decel.time_left, _enemy_stats.acceleration)
	$AnimatedSprite2D.look_at(global_position + direction)

func start_dash():
	decel.start()

func spin():
	if player:
		direction = global_position.direction_to(player.global_position)
	velocity = Vector2.ZERO

func animate_spin():
	tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, "rotation", 4 * TAU, 1.75).as_relative() \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): _state_machine.set_state(_state_machine.states.dash))
