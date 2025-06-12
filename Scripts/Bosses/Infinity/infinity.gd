extends "res://Scripts/Bosses/boss.gd"

@onready var collision_1 = $"Enemy Hitbox/CollisionPolygon2D"
@onready var collision_2 = $"Enemy Hitbox/CollisionShape2D"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var enemy_hitbox = $"Enemy Hitbox"
@onready var fire_rate = $"Fire Rate"
@onready var _state_machine = $StateMachine
@onready var dash_rate = $"Dash Rate"
@onready var dash_time = $"Dash Time"

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")
const WARNING = preload("res://Scenes/Misc/Warning.tscn")

const NUMBER_OF_BULLETS = 5
const NUMBER_OF_DASHES = 3
const DISTANCE = 100

var rotation_speed: float
var current_rotation: float
var tween
var charging: bool
var charging_down: bool
var distance_travelled: float
var previous_position: Vector2
var total_distance: float
var player_direction: Vector2
var can_dash: bool
var dash_count: int
var t: float
var dash_direction: Vector2
var dash_starting_pos: Vector2
var dash_rotation: float
var firing_pos: int
var jump_pitch

func _ready():
	randomize()
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	animated_sprite_2d.rotation += rotation_speed * delta
	enemy_hitbox.rotation += rotation_speed * delta
	current_rotation = animated_sprite_2d.rotation
	if player:
		player_direction = global_position.direction_to(player.global_position)

func idle():
	velocity = velocity.lerp(player_direction * _enemy_stats.speed / 2, _enemy_stats.friction)
	rotation_speed = PI/2

func fire():
	velocity = velocity.lerp(player_direction * _enemy_stats.speed, _enemy_stats.acceleration)
	rotation_speed = TAU
	
	if fire_rate.is_stopped():
		var pos
		Game.audio_manager.play(Game.audio_manager.laser_shot)
		for i in NUMBER_OF_BULLETS:
			var bullet = BULLET.instantiate()
			bullet.damage = _enemy_stats.weapon_damage
			bullet.range = _enemy_stats.weapon_range
			bullet.speed = _enemy_stats.weapon_speed
			if firing_pos % 2 == 0:
				bullet.direction = Vector2.RIGHT.rotated(current_rotation - PI / 2 - PI / (NUMBER_OF_BULLETS - 1) * i)
				pos = collision_1.global_position
			else:
				bullet.direction = Vector2.LEFT.rotated(current_rotation + PI / 2 - PI / (NUMBER_OF_BULLETS - 1) * i)
				pos = collision_2.global_position
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = collision_1.global_position
		
		firing_pos += 1
		
		fire_rate.start()

func shoot():
	if not charging:
		distance_travelled = 0
		previous_position = global_position
		total_distance = DISTANCE
		return
	if global_position.x > abs(735):
		return
	if global_position.y > abs(350):
		return
	
	distance_travelled = previous_position.distance_to(global_position)
	total_distance += distance_travelled
	previous_position = global_position
	if total_distance >= DISTANCE:
		var bullet = BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range * 2
		bullet.speed = _enemy_stats.weapon_speed * 1.5
		if not charging_down:
			bullet.direction = Vector2.UP if global_position.y > 0 else Vector2.DOWN
		else:
			bullet.direction = global_position.direction_to(player.global_position)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		total_distance = 0

func dashing():
	if not can_dash or not dash_rate.is_stopped():
		return
	
	rotation_speed = dash_rotation * sign(dash_direction.x)
	t += get_physics_process_delta_time() * 2
	t = min(t, 1)
	global_position = dash_starting_pos.lerp(dash_starting_pos + dash_direction * 600, t)
	if dash_time.is_stopped():
		if dash_count >= NUMBER_OF_DASHES:
			can_dash = false
			dash_count = 0
			_state_machine.set_state(_state_machine.states.idle)
		else:
			dash_rate.start()

func dash():
	tween = get_tree().create_tween()
	tween.tween_property(self, "velocity", Vector2.ZERO, 1)
	tween.parallel().tween_property(self, "rotation_speed", 8 * PI * sign(player_direction.x), 1)
	tween.tween_callback(func():
		can_dash = true
		dash_rate.start()
	)

func charge():
	tween = get_tree().create_tween()
	tween.tween_property(self, "velocity", Vector2.ZERO, 0.5)
	tween.parallel().tween_property(self, "rotation_speed", -6 * PI, 2)
	tween.tween_callback(func():
		_enemy_stats.damage = 0
		Game.audio_manager.play(Game.audio_manager.laser_whoosh_3)
	)
	tween.tween_property(self, "global_position:x", -1090, 0.25).set_ease(Tween.EASE_IN)
	tween.tween_interval(0.75)
	tween.tween_callback(func():
		charging = false
		rotation_speed = 6 * PI
		velocity = Vector2.ZERO
		global_position = Vector2(-1090, [255, -255].pick_random())
	)
	tween.tween_callback(func(): _enemy_stats.damage = 1)
	tween.tween_callback(spawn_warning)
	tween.tween_interval(1)
	tween.tween_callback(func():
		Game.audio_manager.play(Game.audio_manager.laser_whoosh)
		charging = true
	)
	tween.tween_property(self, "global_position:x", 1090, 0.5)
	tween.tween_callback(func():
		charging = false
		rotation_speed = -6 * PI
		velocity = Vector2.ZERO
		global_position = Vector2(1090, -global_position.y)
	)
	tween.tween_callback(spawn_warning)
	tween.tween_interval(1)
	tween.tween_callback(func():
		Game.audio_manager.play(Game.audio_manager.laser_whoosh)
		charging = true
	)
	tween.tween_property(self, "global_position:x", -1090, 0.5)
	tween.tween_callback(func():
		velocity = Vector2.ZERO
		global_position = Vector2(0, -700)
		
		charging = false
		var warning = WARNING.instantiate()
		warning.rotation = PI/2
		get_tree().current_scene.add_child(warning)
		warning.global_position = Vector2(0, -190)
	)
	tween.tween_interval(1)
	tween.tween_callback(func(): Game.audio_manager.play(Game.audio_manager.laser_whoosh_2))
	tween.tween_property(self, "global_position:y", 0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		Game.audio_manager.play(Game.audio_manager.big_laser)
		for i in NUMBER_OF_BULLETS * 3:
			var bullet = BULLET.instantiate()
			bullet.damage = _enemy_stats.weapon_damage
			bullet.range = _enemy_stats.weapon_range
			bullet.speed = _enemy_stats.weapon_speed
			bullet.direction = Vector2.RIGHT.rotated(current_rotation - PI / 2 - PI / (NUMBER_OF_BULLETS * 3 - 1) * i)
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = collision_1.global_position
			
			var bullet_2 = BULLET.instantiate()
			bullet_2.damage = _enemy_stats.weapon_damage
			bullet_2.range = _enemy_stats.weapon_range
			bullet_2.speed = _enemy_stats.weapon_speed
			bullet_2.direction = Vector2.RIGHT.rotated(current_rotation + PI / 2 - PI / (NUMBER_OF_BULLETS * 3 - 1) * i)
			get_tree().current_scene.add_child(bullet_2)
			bullet_2.global_position = collision_2.global_position
	)
	tween.parallel().tween_property(self, "rotation_speed", PI / 2, 0.5)
	tween.tween_callback(func(): _state_machine.set_state(_state_machine.states.idle))

func spawn_warning():
	var warning = WARNING.instantiate()
	warning.flip_h = global_position.x > 0
	get_tree().current_scene.add_child(warning)
	warning.global_position.y = global_position.y
	warning.global_position.x = sign(global_position.x) * 576

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Reverse Dash":
		animated_sprite_2d.play("Idle")

func _exit_tree():
	if tween:
		tween.kill()

func _on_dash_rate_timeout():
	dash_direction = player_direction
	t = 0
	dash_count += 1
	dash_starting_pos = global_position
	dash_rotation = abs(rotation_speed)
	Game.audio_manager.play(Game.audio_manager.laser_whoosh_4)
	dash_time.start()
	
