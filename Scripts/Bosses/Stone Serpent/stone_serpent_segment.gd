extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

signal jump_shoot
signal shoot_finished(segment)

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $state_machine
@onready var stomp_SFX = $Stomp
@onready var dice_roll_SFX = $DiceRoll

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")
const SNAKE_BULLET = preload("res://Scenes/Enemies/Weapons/Snake Bullet.tscn")
var damage_number = preload("res://Scenes/UI/damage_number.tscn")

const SPREAD = PI/8

var lead_segment
var previous_segment
var serpent
var speed: float
var direction: Vector2
var positions: Array
var new_directions: Array

## for shooting animation when switching directions mid-animation
var current_frame = 0
var current_progress = 0

func _ready():
	super._ready()
	player = Targets.get_player()
	lead_segment.jump_shoot.connect(shoot_after_jump)
	$Hitbox/Side.set_deferred("disabled", direction.x == 0)
	$Hitbox/Down.set_deferred("disabled", direction.y == 0)
	_enemy_stats.spawn_damage_number.connect(transfer_damage)
	_enemy_stats.spawn_damage_number.connect(spawn_damage_number)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.change_color.connect(change_color)

func _physics_process(delta):
	# once all the enemies in the current room are defeated, destroy the obstacle
	if not is_instance_valid(serpent):
		die()
		return
	
	speed = serpent._enemy_stats.speed
	if player == null: # keep looking for the player until they are found
		player = Targets.get_player()
	if is_in_area and damage_buffer.is_stopped() and _enemy_stats.damage > 0:
		player._player_stats.take_damage(_enemy_stats.damage)
		damage_buffer.start()

func idle():
	velocity = direction * speed
	play_idle()
	check_position()
	move_and_slide()

func shoot():
	velocity = direction * speed
	
	if direction.x != 0:
		current_frame = animated_sprite_2d.get_frame()
		current_progress = animated_sprite_2d.get_frame_progress()
		animated_sprite_2d.play("Shoot Side")
		animated_sprite_2d.set_frame_and_progress(current_frame, current_progress)
		animated_sprite_2d.offset.y = 2
	else:
		current_frame = animated_sprite_2d.get_frame()
		current_progress = animated_sprite_2d.get_frame_progress()
		animated_sprite_2d.play("Shoot Down")
		animated_sprite_2d.set_frame_and_progress(current_frame, current_progress)
		animated_sprite_2d.offset.y = 0
	
	check_position()
	
	move_and_slide()

func jump_shot():
	if direction.x != 0:
		animated_sprite_2d.play("Jump Side")
		animated_sprite_2d.offset.y = 2
	else:
		animated_sprite_2d.play("Jump Down")
		animated_sprite_2d.offset.y = 0

func shoot_after_jump():
	animated_sprite_2d.stop()
	jump_shot()

func jump():
	play_idle()

func charge():
	pass

func check_position():
	if positions.is_empty():
		return
	
	match direction:
		Vector2.UP:
			if global_position.y <= positions[0].y:
				change_direction()
		Vector2.DOWN:
			if global_position.y >= positions[0].y:
				change_direction()
		Vector2.LEFT:
			if global_position.x <= positions[0].x:
				change_direction()
		Vector2.RIGHT:
			if global_position.x >= positions[0].x:
				change_direction()

func change_direction():
	global_position = positions.pop_front()
	direction = new_directions.pop_front()
	$Hitbox/Side.set_deferred("disabled", direction.x == 0)
	$Hitbox/Down.set_deferred("disabled", direction.y == 0)

func _on_animated_sprite_2d_animation_finished():
	if _state_machine.state == _state_machine.states.jump:
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
		jump_shoot.emit()
		shoot_finished.emit(self)
		play_idle()
		return
	
	if animated_sprite_2d.animation == "Shoot Side" or animated_sprite_2d.animation == "Shoot Down":
		var bullet = SNAKE_BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed
		
		var offset: Vector2
		if direction.x == 0:
			if global_position.x > 0:
				bullet.direction = Vector2.LEFT
			else:
				bullet.direction = Vector2.RIGHT
			offset = bullet.direction * 64
		else:
			if global_position.y > 0:
				bullet.direction = Vector2.UP
			else:
				bullet.direction = Vector2.DOWN
		_state_machine.set_state(_state_machine.states.idle)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + offset
		dice_roll_SFX.play()

func play_idle():
	if direction.x != 0:
		animated_sprite_2d.play("Idle Side")
		animated_sprite_2d.offset.y = 2
	else:
		animated_sprite_2d.play("Idle Down")
		animated_sprite_2d.offset.y = 0

func transfer_damage(amount):
	serpent._enemy_stats.take_damage_no_red(amount)

func spawn_damage_number(damage: float):
	var value = str(round(damage))
	var pos = global_position
	var height = 20
	var spread = 75
	var damage_text = damage_number.instantiate()
	get_tree().current_scene.add_child(damage_text, true)
	damage_text.global_position = global_position
	damage_text.set_and_animate_damage(damage, pos, height, spread)

func update_health(new_health):
	_enemy_stats.set_health(_enemy_stats.max_health)

func change_color():
	animated_sprite_2d.material.set("shader_parameter/tint_factor", 0.8)
	await get_tree().create_timer(0.05, false).timeout
	animated_sprite_2d.material.set("shader_parameter/tint_factor", 0.0)
