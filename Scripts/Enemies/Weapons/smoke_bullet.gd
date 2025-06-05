extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var acceleration = $Acceleration
@onready var delay = $Delay

var UPWARD_SPEED = 200
var tween
var size

func _ready():
	size = scale
	scale = Vector2.ZERO
	randomize()
	super._ready()
	UPWARD_SPEED = randf_range(150, 300)
	acceleration.start(randf_range(3, 5))
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", size, 0.5)

func update_position(delta):
	super.update_position(delta)
	if delay.is_stopped():
		position.y -= UPWARD_SPEED * delta * (1 - acceleration.time_left / acceleration.wait_time)

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
	else:
		if tween:
			tween.kill()
		queue_free()
