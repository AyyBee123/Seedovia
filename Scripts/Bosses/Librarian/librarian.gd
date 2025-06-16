extends "res://Scripts/Bosses/boss.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $StateMachine
@onready var eye_time = $"Eye Time"
@onready var broom_fire_rate = $"Broom Fire Rate"
@onready var staff_marker = $"Staff Marker"
@onready var broom_marker = $"Broom Marker"
@onready var eye_marker = $"Eye Marker"
@onready var laser_whoosh = $LaserWhoosh
@onready var laser_shot = $LaserWithReverb
@onready var sparkle = $Sparkle
@onready var bubble_pop_2 = $BubblePop2

const DASH_TRAIL = preload("res://Scenes/Player/Dash Trail.tscn")
const STAFF = preload("res://Scenes/Misc/Staff.tscn")
const BROOM = preload("res://Scenes/Misc/Broom.tscn")
const BIG_HOMING_BULLET = preload("res://Scenes/Enemies/Weapons/Big Homing Bullet.tscn")
const SMALL_HOMING_BULLET = preload("res://Scenes/Enemies/Weapons/Small Homing Bullet.tscn")
const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const CHARGE_SPEED_MULTIPLIER = 30

var direction: Vector2
var charge_direction: Vector2
var starting_dash_pos: Vector2
var total_dash_distance: float
var dash_distance_travelled: float
var staff
var broom
var tween

func _ready():
	randomize()
	super._ready()
	
	staff = STAFF.instantiate()
	staff.source = self
	staff.z_index = z_index + 1
	staff.scale = scale
	staff.pos = staff_marker
	get_tree().current_scene.add_child.call_deferred(staff)
	staff.global_position = staff_marker.global_position
	
	broom = BROOM.instantiate()
	broom.source = self
	broom.z_index = z_index + 1
	broom.scale = scale
	broom.pos = broom_marker
	get_tree().current_scene.add_child.call_deferred(broom)
	broom.global_position = broom_marker.global_position

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		direction = global_position.direction_to(player.global_position)

func idle():
	velocity = velocity.lerp(direction * _enemy_stats.speed, _enemy_stats.friction)

func eye():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)

func charge():
	velocity = velocity.lerp(charge_direction * _enemy_stats.speed * CHARGE_SPEED_MULTIPLIER, _enemy_stats.acceleration)
	
	dash_distance_travelled = starting_dash_pos.distance_to(global_position)
	total_dash_distance += dash_distance_travelled
	starting_dash_pos = global_position
	if total_dash_distance >= 50:
		sparkle.play()
		var trail = DASH_TRAIL.instantiate()
		
		# get the current texture in the animation
		var frame_index: int = animated_sprite_2d.get_frame()
		var animation_name: String = animated_sprite_2d.animation
		var sprite_frames: SpriteFrames = animated_sprite_2d.get_sprite_frames()
		var current_texture: Texture2D = sprite_frames.get_frame_texture(animation_name, frame_index)
		trail.texture = current_texture
		
		# shoot homing shot
		var bullet = SMALL_HOMING_BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.speed = _enemy_stats.weapon_speed
		bullet.range = _enemy_stats.weapon_range
		bullet.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		bullet.rotation_speed = 10
		bullet.home_time = 0.1
		bullet.ignore_first_collision = true
		get_tree().current_scene.add_child.call_deferred(bullet)
		bullet.global_position = staff.marker.global_position
		
		trail.flip_h = animated_sprite_2d.flip_h
		trail.scale = scale
		get_tree().current_scene.add_child(trail)
		trail.global_position = global_position + animated_sprite_2d.position
		total_dash_distance = 0

func set_direction():
	laser_whoosh.play()
	charge_direction = Vector2.RIGHT if global_position.x < 0 else Vector2.LEFT

func broom_attack():
	tween = get_tree().create_tween()
	tween.tween_property(broom, "rotation", TAU, 1).as_relative()
	tween.tween_callback(func(): _state_machine.set_state(_state_machine.states.idle))

func _on_charge_detect_body_entered(body):
	_state_machine.set_state(_state_machine.states.idle)

func _on_eye_time_timeout():
	laser_shot.play()
	velocity = Vector2.UP * _enemy_stats.speed * CHARGE_SPEED_MULTIPLIER
	
	# shoot homing shot
	var bullet = BIG_HOMING_BULLET.instantiate()
	bullet.damage = _enemy_stats.weapon_damage
	bullet.speed = _enemy_stats.weapon_speed
	bullet.range = _enemy_stats.weapon_range
	bullet.direction = Vector2.DOWN
	bullet.rotation_speed = 8
	bullet.home_time = 0.6
	bullet.ignore_first_collision = true
	get_tree().current_scene.add_child.call_deferred(bullet)
	bullet.global_position = eye_marker.global_position
	
	_state_machine.set_state(_state_machine.states.idle)

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Eye Open":
		animated_sprite_2d.play("Eye")

func _on_broom_fire_rate_timeout():
	bubble_pop_2.play()
	# shoot homing shot
	var bullet = SMALL_HOMING_BULLET.instantiate()
	bullet.damage = _enemy_stats.weapon_damage
	bullet.speed = _enemy_stats.weapon_speed
	bullet.range = _enemy_stats.weapon_range
	bullet.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	bullet.rotation_speed = 10
	bullet.home_time = 0.1
	bullet.ignore_first_collision = true
	get_tree().current_scene.add_child.call_deferred(bullet)
	bullet.global_position = broom.marker.global_position
	broom_fire_rate.start()

func _exit_tree():
	if tween:
		tween.kill()
