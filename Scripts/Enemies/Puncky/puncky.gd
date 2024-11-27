extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D

var puck
var _is_ready: bool
var _punched: bool
var _no_pucks: bool
var _puck_launched: bool
var puck_direction: Vector2

func find_puck():
	var pucks = get_tree().get_nodes_in_group("Puck")
	if pucks:
		return pucks.pick_random()
	else:
		return null

func idle():
	_puck_launched = false
	puck = find_puck()

func ready_up():
	if puck:
		var direction = puck.global_position - $Shadow.global_position
		velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
		if ($Shadow.global_position - puck.global_position).length() <= 10:
			_is_ready = true
	else:
		var direction = global_position # leaves the room
		velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)

func punch():
	velocity = Vector2.ZERO
	if puck and not _puck_launched:
		puck_direction = (player.global_position - puck.global_position).normalized()
		puck.launch_puck(puck_direction)
		_puck_launched = true

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Ready Beginning":
		animated_sprite_2d.play("Ready")
		if puck == null: # if there are no pucks in the level
			_no_pucks = true
	if animated_sprite_2d.animation == "Punch":
		_punched = true
		puck = null
		puck_direction = Vector2.ZERO

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
