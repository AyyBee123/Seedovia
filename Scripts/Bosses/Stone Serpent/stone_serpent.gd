extends "res://Scripts/Bosses/boss.gd"

signal jump_shoot

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $StateMachine
@onready var stomp_SFX = $Stomp

const STONE_SERPENT_SEGMENT = preload("res://Scenes/Bosses/Stone Serpent Segment.tscn")
const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const SPREAD = PI/8
const NUMBER_OF_SEGMENTS = 6
const DISTANCE_BETWEEN_SEGMENTS = 150
const change_dir_chance = 0.002

var direction: Vector2
var segments: Array
var lead_segment

func _ready():
	super._ready()
	direction = Vector2(-1, 0)
	randomize()
	for i in NUMBER_OF_SEGMENTS:
		var segment = STONE_SERPENT_SEGMENT.instantiate()
		segment.serpent = self
		segment.direction = direction
		# assign the leading segment for each segment to directly follow
		if lead_segment:
			segment.lead_segment = segments[i - 1]
		else:
			segment.lead_segment = self
		segment.shoot_finished.connect(shoot_finished)
		get_tree().current_scene.add_child.call_deferred(segment)
		segment.global_position = global_position + Vector2(DISTANCE_BETWEEN_SEGMENTS * (i + 1) - 30, 0)
		segments.append(segment)
		lead_segment = segment

func idle():
	velocity = direction * _enemy_stats.speed
	
	if randf() <= change_dir_chance:
		set_random_direction()
	
	move_and_slide()

func set_random_direction():
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var old_direction = direction
	var new_direction = directions.pick_random()
	
	if new_direction == Vector2.UP and not $"Detect Up".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	if new_direction == Vector2.DOWN and not $"Detect Down".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	if new_direction == Vector2.LEFT and not $"Detect Left".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	if new_direction == Vector2.RIGHT and not $"Detect Right".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	
	# only change direction left or right relative to the current direction
	if abs(old_direction) == abs(new_direction):
		set_random_direction()
		return
	
	direction = new_direction
	var dist = global_position.distance_to(segments[0].global_position)
	if dist > DISTANCE_BETWEEN_SEGMENTS:
		global_position -= (dist - DISTANCE_BETWEEN_SEGMENTS) * old_direction
	
	for seg in segments:
		seg.positions.append(global_position)
		seg.new_directions.append(direction)
	
	match direction:
		Vector2.UP:
			play_anim("Idle Up")
		Vector2.DOWN:
			play_anim("Idle Down")
		Vector2.LEFT:
			play_anim("Idle Side")
		Vector2.RIGHT:
			play_anim("Idle Side")

func charge():
	pass

func start_jump():
	for seg in segments:
		seg._state_machine.state = seg._state_machine.states.jump

func jump():
	pass

func start_charge():
	for seg in segments:
		seg._state_machine.state = seg._state_machine.states.charge
	animated_sprite_2d.play("Charge Beginning")

func shoot_finished(s):
	if s == segments[-1]:
		_state_machine.state = _state_machine.states.idle
		for seg in segments:
			seg._state_machine.state = seg._state_machine.states.idle

func play_anim(anim: String):
	if animated_sprite_2d.animation != anim:
		animated_sprite_2d.play(anim)
	animated_sprite_2d.flip_h = direction == Vector2.RIGHT
	if animated_sprite_2d.flip_h:
		animated_sprite_2d.offset.x = 12
		$"Enemy Hitbox/Side".position.x = 12
	else:
		animated_sprite_2d.offset.x = -12
		$"Enemy Hitbox/Side".position.x = -12

func _on_animated_sprite_2d_animation_changed():
	$"Enemy Hitbox/Up".set_deferred("disabled", $AnimatedSprite2D.animation != "Idle Up")
	$"Enemy Hitbox/Down".set_deferred("disabled", $AnimatedSprite2D.animation != "Idle Down")
	$"Enemy Hitbox/Side".set_deferred("disabled", $AnimatedSprite2D.animation != "Idle Side")

func _on_detect_up_body_entered(body):
	set_random_direction()

func _on_detect_down_body_entered(body):
	set_random_direction()

func _on_detect_right_body_entered(body):
	set_random_direction()

func _on_detect_left_body_entered(body):
	set_random_direction()

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Jump":
		Targets.get_camera().add_trauma(0.2)
		var angle = 0
		while angle < TAU:
			var bullet = BULLET.instantiate()
			bullet.direction = Vector2.RIGHT.rotated(angle)
			bullet.speed = _enemy_stats.weapon_speed * 0.75
			bullet.range = _enemy_stats.weapon_range
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = global_position
			angle += SPREAD
		stomp_SFX.play()
		segments[0].shoot_after_jump()
	if animated_sprite_2d.animation == "Charge Beginning":
		animated_sprite_2d.play("Charge")
