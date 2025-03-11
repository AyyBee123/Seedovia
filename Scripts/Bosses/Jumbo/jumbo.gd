extends "res://Scripts/Bosses/boss.gd"

## y = 37 when changed to wall
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var _state_machine = $StateMachine
@onready var splat_2_SFX = $Splat2
@onready var splat_SFX = $Splat
@onready var stomp_SFX = $Stomp
@onready var stomp_2_SFX = $Stomp2
@onready var wall_duration = $"Wall Duration"
@onready var wall_fire_rate = $"Wall Fire Rate"
@onready var start_delay = $"Start Delay"
@onready var launch_SFX = $Launch
@onready var jellofish_time = $"Jellofish Time"
@onready var jellofish_launch_delay = $"Jellofish Launch Delay"
@onready var shake_time = $"Shake Time"
@onready var chocolate_bottom_left = $"Chocolate Bottom Left"
@onready var chocolate_top_right = $"Chocolate Top Right"
@onready var chocolate_rate = $"Chocolate Rate"
@onready var center = $Center

var dist: Vector2 # declared in the state machine script when entering the "jump_to_transform" state
var _can_move: bool = false: set = set_move
var direction: Vector2
var slimes := []
var stop_shooting: bool

var number_of_slimes: int:
	get:
		return get_tree().get_nodes_in_group("Slime").size()
var number_of_jellofish: int:
	get:
		return get_tree().get_nodes_in_group("Jellofish").size()
var number_of_puddlings: int:
	get:
		return get_tree().get_nodes_in_group("Puddling").size()

const SLIME = preload("res://Scenes/Enemies/Slime.tscn")
const JELLOFISH = preload("res://Scenes/Enemies/Jellofish.tscn")
const JELLO = preload("res://Scenes/Enemies/Jello.tscn")
const JELLOFISH_PROJECTILE = preload("res://Scenes/Enemies/Weapons/Jellofish Projectile.tscn")
const JELLOFISH_PROJECTILE_LEFT = preload("res://Scenes/Enemies/Weapons/Jellofish Projectile Left.tscn")
const CHOCOLATE_PROJECTILE = preload("res://Scenes/Enemies/Weapons/Chocolate Projectile.tscn")
const PUDDLING = preload("res://Scenes/Enemies/Puddling.tscn")

var KNOCKBACK = preload("res://Scenes/Misc/Player Knockback.tscn")

const AMOUNT_OF_SLIMES = 4
const MAX_SLIMES = 3

func _ready():
	super._ready()
	$Shadow.visible = false
	slimes.append(SLIME)

func _physics_process(delta):
	super._physics_process(delta)

func idle():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	if player:
		direction = player.global_position - global_position

func jump():
	if _can_move:
		velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	else:
		velocity = Vector2.ZERO

func shake():
	if shake_time.is_stopped():
		shake_time.start()
	if chocolate_rate.is_stopped():
		chocolate_rate.start()
		var choco = CHOCOLATE_PROJECTILE.instantiate()
		var bottom_left = chocolate_bottom_left.global_position
		var top_right = chocolate_top_right.global_position
		var pos = Vector2(randf_range(bottom_left.x, top_right.x), randf_range(bottom_left.y, top_right.y))
		choco.direction = (pos - center.global_position).normalized()
		get_tree().current_scene.add_child(choco)
		choco.global_position = pos

func wall():
	if stop_shooting:
		return
	if start_delay.is_stopped() and wall_duration.is_stopped():
		start_delay.start()
	if wall_duration.is_stopped():
		wall_duration.start()
	if wall_fire_rate.is_stopped() and start_delay.is_stopped():
		wall_fire_rate.start()
		var jellofish_proj_left = JELLOFISH_PROJECTILE_LEFT.instantiate()
		jellofish_proj_left.direction = Vector2.LEFT
		var jellofish_proj = JELLOFISH_PROJECTILE.instantiate()
		jellofish_proj.direction = Vector2.RIGHT
		get_tree().current_scene.add_child(jellofish_proj)
		get_tree().current_scene.add_child(jellofish_proj_left)
		jellofish_proj.global_position = Vector2(global_position.x, randf_range(-365, 365))
		jellofish_proj_left.global_position = Vector2(global_position.x, randf_range(-365, 365))
		await get_tree().create_timer(0.1).timeout
		launch_SFX.play()

func jump_to_transform():
	if _can_move:
		velocity = dist / 1.15
	else:
		velocity = Vector2.ZERO

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "Short Jump":
		if animated_sprite_2d.frame == 2:
			splat_2_SFX.play()
		if animated_sprite_2d.frame == 5:
			Targets.get_camera().add_trauma(0.2)
			stomp_SFX.play()
			splat_SFX.play()
			for i in AMOUNT_OF_SLIMES:
				var slime = slimes.pick_random().instantiate()
				slime.visible = false # gets rid of the single frame where the slime pops up on the screen
				slime.get_node("Enemy Hitbox/CollisionPolygon2D").disabled = true
				get_tree().current_scene.add_child(slime)
				slime.global_position = Vector2(randf_range(-750, 750), randf_range(-366, 366))
				slime._state_machine.set_state(slime._state_machine.states.spawn)
				await get_tree().create_timer(randf_range(0.05, 0.25)).timeout # add delay between spawns

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Short Jump":
		_state_machine.set_state(_state_machine.states.idle)
	if animated_sprite_2d.animation == "Transform":
		_state_machine.set_state(_state_machine.states.wall)
	if animated_sprite_2d.animation == "Transform Reverse":
		_state_machine.set_state(_state_machine.states.idle)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Jump":
		if _state_machine.state == _state_machine.states.jump:
			_state_machine.set_state(_state_machine.states.idle)
		if _state_machine.state == _state_machine.states.jump_to_transform:
			_state_machine.set_state(_state_machine.states.idle_to_transform)

func set_move(value: bool):
	_can_move = value

func play_jump():
	splat_2_SFX.play()

func play_land():
	stomp_SFX.play()
	splat_SFX.play()

func _on_wall_duration_timeout():
	stop_shooting = true
	if number_of_jellofish >= 2:
		_state_machine.set_state(_state_machine.states.transform_reverse)
		return
	jellofish_launch_delay.start()
	jellofish_time.start()

func _on_jellofish_time_timeout():
	_state_machine.set_state(_state_machine.states.transform_reverse)

func _on_jellofish_launch_delay_timeout():
	var positions_y = [-192, 192]
	for i in positions_y:
		var jellofish = JELLOFISH.instantiate()
		jellofish.direction = Vector2(-global_position.x, 0).normalized()
		jellofish.launch_rotation = jellofish.direction.angle() + PI/2
		jellofish.starting_state = 2 # launch state
		get_tree().current_scene.add_child(jellofish)
		jellofish.global_position = Vector2(global_position.x, i)

func enable_wall_collisions():
	$"Wall Body/CollisionShape2D".disabled = false
	$"Wall Area/CollisionShape2D".disabled = false

func disable_wall_collisions():
	$"Wall Body/CollisionShape2D".disabled = true
	$"Wall Area/CollisionShape2D".disabled = true

func enable_collisions():
	$"Enemy Hitbox/CollisionPolygon2D".disabled = false
	$CollisionPolygon2D.disabled = false

func disable_collisions():
	$"Enemy Hitbox/CollisionPolygon2D".disabled = true
	$CollisionPolygon2D.disabled = true

func _on_wall_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body # just in case
		is_in_area = true

func _on_wall_area_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func _on_shake_time_timeout():
	if number_of_puddlings < 1:
		var puddling = PUDDLING.instantiate()
		var bottom_left = chocolate_bottom_left.global_position
		var top_right = chocolate_top_right.global_position
		var pos = Vector2(randf_range(bottom_left.x, top_right.x), randf_range(bottom_left.y, top_right.y))
		puddling.launch_direction = (pos - center.global_position).normalized()
		puddling.launch_speed = randf_range(200, 500)
		puddling.starting_state = 3 # spawn state
		get_tree().current_scene.add_child(puddling)
		puddling.global_position = pos
	_state_machine.set_state(_state_machine.states.idle)
