extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var frame_time = $"Frame Time"

const LENGTH = 5 # the number of squares that form the snake

var segment_num: int
var leading_segment
var distance_per_frame

var previous_pos
var previous_dir
var tick_delay: int
var change_dir: int
var _direction_changed: bool

func _ready():
	super._ready()
	randomize()
	change_dir = randi_range(2, 30)
	frame_time.wait_time = 1.0 / speed * 100
	distance_per_frame = texture.get_size().x * scale.x
	tick_delay = segment_num

func _physics_process(delta):
	super._physics_process(delta)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		position_initialized = true
		if segment_num < LENGTH - 1: # subtract 1 to exclude the first segment
			var bullet = duplicate()
			bullet.segment_num = segment_num + 1
			bullet.leading_segment = self
			bullet.damage = damage
			bullet.range = range
			bullet.speed = speed
			bullet.direction = direction
			get_tree().current_scene.add_child.call_deferred(bullet)
			bullet.global_position = global_position
		frame_time.start()

func update_position(delta):
	pass

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
	else:
		queue_free()

func _on_frame_time_timeout():
	if tick_delay > 0:
		tick_delay -= 1
		frame_time.start()
		return
	var old_dir = direction
	var old_pos = position
	if is_instance_valid(leading_segment):
		position = leading_segment.previous_pos
		direction = leading_segment.previous_dir
	else:
		if change_dir > 0:
			change_dir -= 1
		else:
			if not _direction_changed:
				_direction_changed = true
				direction = direction.rotated(-PI/2) if randf() < 0.5 else direction.rotated(PI/2)
		position += distance_per_frame * direction
	frame_time.start()
	previous_dir = old_dir
	previous_pos = old_pos
