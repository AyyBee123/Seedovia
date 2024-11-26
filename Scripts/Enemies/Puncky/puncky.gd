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
	return pucks.pick_random()

func idle():
	_puck_launched = false

func ready_up():
	if puck:
		var direction = puck.global_position - $Shadow.global_position
		velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
		if ($Shadow.global_position - puck.global_position).length() <= 10:
			_is_ready = true

func punch():
	velocity = Vector2.ZERO
	if puck and not _puck_launched:
		puck_direction = (player.global_position - puck.global_position).normalized()
		puck.launch_puck(puck_direction)
		_puck_launched = true

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Ready Beginning":
		animated_sprite_2d.play("Ready")
		puck = find_puck()
		if puck == null: # if there are no pucks in the level
			_no_pucks = true
	if animated_sprite_2d.animation == "Punch":
		_punched = true
		puck = null
		puck_direction = Vector2.ZERO
