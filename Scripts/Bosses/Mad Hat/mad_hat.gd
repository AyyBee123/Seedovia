extends "res://Scripts/Bosses/boss.gd"

@onready var _state_machine = $StateMachine
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_polygon_2d = $"Enemy Hitbox/CollisionPolygon2D"
@onready var mad_fire_rate = $"Mad Fire Rate"
@onready var hand_rate = $"Hand Rate"
@onready var what_SFX = $What
@onready var mad_sfx_rate = $"Mad SFX Rate"
@onready var fart_SFX = $Fart
@onready var boing_SFX = $Boing
@onready var boing_2_SFX = $Boing2
@onready var pick_up_SFX = $PickUp

const MAD_HAT_HAND = preload("res://Scenes/Bosses/Mad Hat Hand.tscn")
const FALLING_BULLET = preload("res://Scenes/Enemies/Weapons/Falling Bullet.tscn")
const RING_OF_HATS = preload("res://Scenes/Enemies/Weapons/Ring of Hats.tscn")
const RIGHT_HAND = preload("res://Scenes/Enemies/Weapons/Right Hand.tscn")
const LEFT_HAND = preload("res://Scenes/Enemies/Weapons/Left Hand.tscn")
const DOWN_HAND = preload("res://Scenes/Enemies/Weapons/Down Hand.tscn")
const UP_HAND = preload("res://Scenes/Enemies/Weapons/Up Hand.tscn")
const BIG_FALLING_BULLET = preload("res://Scenes/Enemies/Weapons/Big Falling Bullet.tscn")
const MAD_FPS_CAP = 1.0 / 20.0

var tween_x
var tween_y
var mad_fps: float
var last_mad_frame: int
var mad_fps_cap: float = 1.0 / 20.0 # 20 fps
var left_hand
var right_hand

# variables for hats state
var hat_tween
var ring_direction: Vector2
var side_index: int = -1
var charge_area_range: Vector2
var charge_area_direction: Vector2
var charge_pos: Vector2
var hands_ready: bool

func _ready():
	randomize()
	super._ready()
	for i in [-1, 1]:
		var hand = MAD_HAT_HAND.instantiate()
		hand.mad_hat = self
		hand.pos = Vector2(250 * i, 250)
		if i == 1:
			right_hand = hand
			hand.get_node("AnimatedSprite2D").flip_h = true
			hand.get_node("AnimatedSprite2D").position.x = -10
		else:
			left_hand = hand
		get_tree().current_scene.add_child.call_deferred(hand)

func idle():
	if player:
		velocity = velocity.lerp(player.global_position.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	_enemy_stats.damage = 0

func mad():
	if mad_sfx_rate.is_stopped():
		what_SFX.play()
		mad_sfx_rate.start()
	mad_fps += get_physics_process_delta_time()
	if mad_fps >= mad_fps_cap:
		var rnd = randi_range(0, 6)
		while last_mad_frame == rnd: # keep looping until both numbers are not equal to each other
			rnd = randi_range(0, 6)
		animated_sprite_2d.frame = rnd
		last_mad_frame = rnd
		mad_fps = 0
	if mad_fire_rate.is_stopped():
		mad_fire_rate.start()
		var bullet = FALLING_BULLET.instantiate()
		bullet.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		bullet.temp_speed = _enemy_stats.weapon_speed
		bullet.start_pos = $Marker2D.position.y
		bullet.end_pos = $Shadow.position.y
		bullet.range = 999999
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = $Shadow.global_position + Vector2(randf_range(-1, 1) * 72, randf_range(-1, 1) * 16)

func hats():
	if not (right_hand._state_machine.state == right_hand._state_machine.states.hats \
			and left_hand._state_machine.state == left_hand._state_machine.states.hats):
		return
	_state_machine.set_state(_state_machine.states.hat_start)

func hat_start():
	if randf() < 0.5:
		ring_direction = Vector2.RIGHT
	else:
		ring_direction = Vector2.LEFT
	hat_tween = get_tree().create_tween()
	
	# wait for hands to be in position
	hat_tween.tween_interval(0.5)
	
	# remove the right hand
	hat_tween.tween_callback(look.bind("Look Right"))
	hat_tween.tween_interval(0.5)
	hat_tween.tween_callback(launch_hand.bind(right_hand, 1, boing_SFX))
	
	# delay before launching second hand
	hat_tween.tween_interval(0.5)
	
	# remove the left hand
	hat_tween.tween_callback(look.bind("Look Left"))
	hat_tween.tween_interval(0.5)
	hat_tween.tween_callback(launch_hand.bind(left_hand, -1, boing_2_SFX))
	
	hat_tween.tween_interval(0.5)
	hat_tween.tween_callback(func(): animated_sprite_2d.play("Idle"))
	hat_tween.tween_interval(0.75)
	
	hat_tween.tween_property(animated_sprite_2d, "position:y", -50, 1).as_relative()
	hat_tween.parallel().tween_property($"Enemy Hitbox/CollisionPolygon2D", "position:y", -50, 1).as_relative()
	hat_tween.parallel().tween_property($Shadow, "scale", Vector2.ONE * 0.75, 1)
	hat_tween.parallel().tween_callback(func(): animated_sprite_2d.play("Magic Beginning"))
	hat_tween.parallel().tween_callback(func(): pick_up_SFX.play())
	
	hat_tween.tween_callback(func(): hands_ready = true)
	hat_tween.parallel().tween_callback(rings)

func spawn_hands():
	if not hands_ready:
		return
	if not hand_rate.is_stopped():
		return
	side_index = randi_range(0, 3) # 0 = UP, 1 = DOWN, 2 = LEFT, 3 = RIGHT
	match side_index:
		0: # DOWN TO UP
			charge_area_range = Vector2(-768, 768)
			charge_area_direction = Vector2(0, 1)
		1: # UP TO DOWN
			charge_area_range = Vector2(-768, 768)
			charge_area_direction = Vector2(0, -1)
		2: # RIGHT TO LEFT
			charge_area_range = Vector2(-384, 384)
			charge_area_direction = Vector2(1, 0)
		3: # LEFT TO RIGHT
			charge_area_range = Vector2(-384, 384)
			charge_area_direction = Vector2(-1, 0)
	# WTF?
	charge_pos = randf_range(charge_area_range.x, charge_area_range.y) \
			* Vector2(abs(charge_area_direction.y), abs(charge_area_direction.x)) + charge_area_direction \
			* Vector2(1115, 735)
	
	var charging_hand
	match side_index:
		0:
			charging_hand = UP_HAND.instantiate()
		1:
			charging_hand = DOWN_HAND.instantiate()
		2:
			charging_hand = LEFT_HAND.instantiate()
		3:
			charging_hand = RIGHT_HAND.instantiate()
	charging_hand.mad_hat = self
	get_tree().current_scene.add_child(charging_hand)
	charging_hand.global_position = charge_pos
	hand_rate.start()

func rings():
	hat_tween = get_tree().create_tween() # start new animation to avoid looping all the previous tween calls
	hat_tween.set_loops(3)
	hat_tween.tween_callback(spawn_ring)
	hat_tween.tween_interval(4.2)
	
	hat_tween.finished.connect(hat_done)

func spawn_ring():
	var ring = RING_OF_HATS.instantiate()
	ring.direction = ring_direction
	get_tree().current_scene.add_child(ring)
	ring.global_position.x = -ring_direction.x * 1600 # start on the opposite side of the screen

func hat_done():
	hat_tween = get_tree().create_tween()
	
	hat_tween.tween_interval(4.2)
	
	# return all nodes to their original position
	hat_tween.tween_property(animated_sprite_2d, "position:y", 50, 1).as_relative()
	hat_tween.parallel().tween_property($"Enemy Hitbox/CollisionPolygon2D", "position:y", 50, 1).as_relative()
	hat_tween.parallel().tween_property($Shadow, "scale", Vector2.ONE, 1)
	hat_tween.tween_callback(func(): hands_ready = false)
	hat_tween.tween_callback(func(): animated_sprite_2d.play("Magic End"))

func look(anim):
	animated_sprite_2d.play(anim)

func launch_hand(hand, sign, sfx):
	sfx.play()
	hand.velocity.x = 1250 * sign

func slam():
	pass

func charge():
	pass

func move_eratically():
	tween_x = get_tree().create_tween()
	tween_y = get_tree().create_tween()
	
	tween_x.set_trans(Tween.TRANS_SINE)
	tween_y.set_trans(Tween.TRANS_SINE)
	
	tween_x.tween_property(self, "position:x", 350, 1.25).set_ease(Tween.EASE_OUT_IN)
	tween_y.tween_property(self, "position:y", 250, 1.25)
	
	tween_x.tween_property(self, "position:x", 730, 0.5).set_ease(Tween.EASE_OUT)
	tween_x.tween_property(self, "position:x", 350, 0.5).set_ease(Tween.EASE_IN)
	tween_y.tween_property(self, "position:y", -250, 1)
	
	tween_x.tween_property(self, "position:x", -350, 1.25).set_ease(Tween.EASE_OUT_IN)
	tween_y.tween_property(self, "position:y", 250, 1.25)
	
	tween_x.tween_property(self, "position:x", -730, 0.5).set_ease(Tween.EASE_OUT)
	tween_x.tween_property(self, "position:x", -350, 0.5).set_ease(Tween.EASE_IN)
	tween_y.tween_property(self, "position:y", -250, 1)
	
	tween_x.finished.connect(move_back)

func kill_tween():
	if tween_x:
		tween_x.kill()
	
	if tween_y:
		tween_y.kill()
	
	_state_machine.set_state(_state_machine.states.idle)

func move_back():
	tween_x = get_tree().create_tween()
	tween_y = get_tree().create_tween()
	
	tween_x.set_trans(Tween.TRANS_SINE)
	tween_y.set_trans(Tween.TRANS_SINE)
	
	
	tween_x.tween_property(self, "position:x", 0, 0.75).set_ease(Tween.EASE_IN_OUT)
	tween_x.parallel().tween_method(madness, MAD_FPS_CAP, 1.0 / 5.0, 0.75)
	tween_y.tween_property(self, "position:y", -180, 0.75).set_ease(Tween.EASE_OUT)
	
	tween_x.finished.connect(kill_tween)

func madness(amount):
	mad_fps_cap = amount

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Magic Beginning":
		animated_sprite_2d.play("Magic")
	if animated_sprite_2d.animation == "Magic End":
		_state_machine.set_state(_state_machine.states.idle)
		right_hand._state_machine.set_state(right_hand._state_machine.states.idle)
		left_hand._state_machine.set_state(left_hand._state_machine.states.idle)
	if animated_sprite_2d.animation == "Spit":
		var bullet = BIG_FALLING_BULLET.instantiate()
		bullet.start_pos = $Marker2D.position.y
		bullet.end_pos = $Shadow.position.y
		bullet.range = 999999
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = $Shadow.global_position
		fart_SFX.play()
		_state_machine.set_state(_state_machine.states.idle)
