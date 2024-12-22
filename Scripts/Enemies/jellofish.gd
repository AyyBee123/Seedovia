extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var marker = $Marker2D
@onready var rotation_point = $"Rotation Point"
@onready var _state_machine = $state_machine
@onready var deceleration = $Deceleration
@onready var trail_rate = $"Trail Rate"

const JELLOFISH_TRAIL = preload("res://Scenes/Enemies/Effects/Jellofish Trail.tscn")
var KNOCKBACK = preload("res://Scenes/Misc/Player Knockback.tscn")

var direction: Vector2
var SPEED_MULTIPLIER = 35
var launch_rotation: float

func _ready():
	super._ready()
	$"Rotation Point/Wall Detect/CollisionShape2D".disabled = true

func idle():
	if player:
		direction = player.global_position - marker.global_position
	velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)

func charge():
	if player:
		direction = player.global_position - global_position
	velocity = Vector2.ZERO
	launch_rotation = direction.angle() + PI/2

func launch():
	$"Rotation Point/Wall Detect/CollisionShape2D".disabled = false
	if not (animated_sprite_2d.animation == "Launch Up" or animated_sprite_2d.animation == "Launch Down"):
		if player.global_position.y - global_position.y < 0:
			animated_sprite_2d.play("Launch Up")
		else:
			animated_sprite_2d.play("Launch Down")
	animated_sprite_2d.rotation = launch_rotation
	rotation_point.rotation = launch_rotation
	$CollisionPolygon2D.rotation = launch_rotation
	$"Enemy Hitbox/CollisionPolygon2D".rotation = launch_rotation
	velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed * SPEED_MULTIPLIER, _enemy_stats.acceleration)
	
	if trail_rate.is_stopped():
		trail_rate.start()
		var trail = JELLOFISH_TRAIL.instantiate()
		get_tree().current_scene.add_child(trail)
		trail.rotation = launch_rotation
		trail.global_position = global_position

func stun():
	$"Rotation Point/Wall Detect/CollisionShape2D".disabled = true
	animated_sprite_2d.rotation = 0
	rotation_point.rotation = 0
	$CollisionPolygon2D.rotation = 0
	$"Enemy Hitbox/CollisionPolygon2D".rotation = 0
	velocity = -direction.normalized() * _enemy_stats.speed * 10 * deceleration.time_left/deceleration.wait_time

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Charge Up":
		_state_machine.set_state(_state_machine.states.launch)
	if animated_sprite_2d.animation == "Stun":
		_state_machine.set_state(_state_machine.states.idle)

func _on_wall_detect_body_entered(body):
	deceleration.start()
	_state_machine.set_state(_state_machine.states.stun)
	if not body.is_in_group("Players"):
		return
	var knockback_scene = KNOCKBACK.instantiate()
	knockback_scene.knockback_direction = Vector2.UP.rotated(launch_rotation).normalized()
	knockback_scene.knockback_speed = 250
	# add node to the player that gives velocity/position change
	body.add_child(knockback_scene)
