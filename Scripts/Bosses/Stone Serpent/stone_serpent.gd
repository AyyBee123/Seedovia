extends "res://Scripts/Bosses/boss.gd"

signal jump_shoot

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $StateMachine
@onready var stomp_SFX = $Stomp
@onready var boing_SFX = $Boing
@onready var failure_drum_SFX = $FailureDrum
@onready var mild_explosion_SFX = $MildExplosion

const ENEMY_EXPLOSION = preload("res://Scenes/Enemies/Weapons/Enemy Explosion.tscn")
const STONE_SERPENT_SEGMENT = preload("res://Scenes/Bosses/Stone Serpent Segment.tscn")
const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const SPREAD = PI/6
const NUMBER_OF_SEGMENTS = 6
const DISTANCE_BETWEEN_SEGMENTS = 150
const change_dir_chance = 0.005

var Z_INDEX
var direction: Vector2
var segments: Array
var lead_segment
var launch_pos: Vector2

func _ready():
	super._ready()
	Z_INDEX = z_index
	direction = Vector2(-1, 0)
	randomize()
	for i in NUMBER_OF_SEGMENTS:
		var segment = STONE_SERPENT_SEGMENT.instantiate()
		segment.serpent = self
		segment.direction = direction
		segment.SPREAD = SPREAD
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

func _physics_process(delta):
	var areas = $"Enemy Hitbox".get_overlapping_areas()
	if areas.size() > 0:
		if areas[0].is_in_group("Seed") and not areas[0].is_in_group("Melee"):
			areas[0].destroy()
		elif not areas[0].is_in_group("Melee"):
			areas[0].queue_free()

func idle():
	velocity = direction * _enemy_stats.speed
	
	$"Detect Up/Detect Up".set_deferred("disabled", false)
	$"Detect Down/Detect Down".set_deferred("disabled", false)
	$"Detect Right/Detect Right".set_deferred("disabled", false)
	$"Detect Left/Detect Left".set_deferred("disabled", false)
	
	if randf() <= change_dir_chance:
		set_random_direction()
	
	move_and_slide()

func set_random_direction():
	if _state_machine.state == _state_machine.states.charge:
		return
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
	boing_SFX.play()
	failure_drum_SFX.play()
	mild_explosion_SFX.play()
	
	$"Detect Up/Detect Up".set_deferred("disabled", true)
	$"Detect Down/Detect Down".set_deferred("disabled", true)
	$"Detect Right/Detect Right".set_deferred("disabled", true)
	$"Detect Left/Detect Left".set_deferred("disabled", true)
	
	$"Enemy Hitbox/Up".set_deferred("disabled", true)
	$"Enemy Hitbox/Down".set_deferred("disabled", true)
	$"Enemy Hitbox/Side".set_deferred("disabled", true)
	
	var tween = get_tree().create_tween()
	
	# launch the head and detach it from the other segments
	tween.tween_property(self, "global_position:x", 2000 * direction.x, 2).as_relative()
	tween.parallel().tween_property(self, "global_position:y", -2000, 2).as_relative()
	tween.parallel().tween_property(animated_sprite_2d, "rotation", 2 * TAU, 2)
	tween.parallel().tween_callback(launch_segments)
	
	tween.tween_interval(4)
	
	tween.tween_callback(func(): 
		for seg in segments: 
			seg._state_machine.state = seg._state_machine.states.restore
	)
	
	# restore the head to its original position
	tween.tween_interval(1.5)
	tween.tween_callback(func(): global_position.y = launch_pos.y)
	tween.parallel().tween_callback(func(): animated_sprite_2d.rotation = 0)
	tween.parallel().tween_property(self, "global_position:x", launch_pos.x, 1).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		animated_sprite_2d.play("Idle Side")
		global_position = launch_pos
		_state_machine.state = _state_machine.states.idle
		for seg in segments:
			seg.global_position = seg.launch_pos
			seg._state_machine.state = seg._state_machine.states.idle
	)

func start_jump():
	for seg in segments:
		seg._state_machine.state = seg._state_machine.states.jump

func launch_segments():
	var exp = ENEMY_EXPLOSION.instantiate()
	exp.is_vanity = true
	exp.size = 1.25
	exp.modulate = "FF0000"
	exp.z_index = Z_INDEX + 1
	get_tree().current_scene.add_child.call_deferred(exp)
	exp.global_position = segments[0].global_position + Vector2(32 * 2.8, 0)
	
	z_index = Z_INDEX + 1
	for seg in segments:
		seg.launch_direction = global_position.direction_to(seg.global_position).rotated(randf_range(-PI/2, PI/2)) \
				.normalized()
		seg._state_machine.state = seg._state_machine.states.launch

func jump():
	pass

func start_charge():
	launch_pos = global_position
	for seg in segments:
		seg._state_machine.state = seg._state_machine.states.charge
		seg.launch_pos = seg.global_position
		seg.play_idle()
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
	if $AnimatedSprite2D.animation == "Charge Beginning" or $AnimatedSprite2D.animation == "Jump":
		return
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
		Targets.get_camera().add_trauma(0.05)
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
		charge()
