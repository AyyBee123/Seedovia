extends "res://Scripts/Enemies/enemy.gd"

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var splat_3 = $Splat2
@onready var splat_2 = $Splat
@onready var big_laser = $BigLaser
@onready var big_laser_2 = $BigLaser2
@onready var mild_explosion = $MildExplosion
@onready var _state_machine = $state_machine

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")
const ENEMY_EXPLOSION = preload("res://Scenes/Enemies/Weapons/Enemy Explosion.tscn")

const NUMBER_OF_PROJECTILES = 12
const SPREAD = PI/8

var _can_move: bool = false: set = set_move
var direction: Vector2
var _jumping: bool
var is_dead: bool

func _ready():
	super._ready()
	$Shadow.visible = false

func _physics_process(delta):
	visible = true
	super._physics_process(delta)

func jump():
	if _can_move:
		velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	else:
		velocity = Vector2.ZERO

func idle():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	if player:
		direction = player.global_position - global_position

func set_move(value: bool):
	_can_move = value

func play_splat_2():
	splat_2.play()
	big_laser.play()

func play_splat_3():
	splat_3.play()

func jump_finished():
	_jumping = false

func die():
	if is_dead:
		return
	is_dead = true
	$"Enemy Hitbox/CollisionPolygon2D".set_deferred("disabled", true)
	$"Health Bar".visible = false
	_state_machine.set_state(_state_machine.states.death)

func shoot():
	Targets.get_camera().add_trauma(0.25)
	
	for i in NUMBER_OF_PROJECTILES:
		var bullet = BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed
		bullet.direction = Vector2.RIGHT.rotated(TAU / NUMBER_OF_PROJECTILES * i)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + bullet.direction * 25
	
	await get_tree().create_timer(0.15).timeout
	
	for i in NUMBER_OF_PROJECTILES:
		var bullet = BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed
		bullet.direction = Vector2.RIGHT.rotated(TAU / NUMBER_OF_PROJECTILES * i + TAU / NUMBER_OF_PROJECTILES / 2)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + bullet.direction * 25

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Death":
		animated_sprite_2d.visible = false
		
		var exp = ENEMY_EXPLOSION.instantiate()
		exp.damage = _enemy_stats.weapon_damage
		exp.size = 1.3
		exp.modulate = "eeeaca"
		exp.z_index = z_index + 1
		get_tree().current_scene.add_child.call_deferred(exp)
		exp.global_position = global_position
		
		Targets.get_camera().add_trauma(0.3)
		
		for i in NUMBER_OF_PROJECTILES:
			var bullet = BULLET.instantiate()
			bullet.damage = _enemy_stats.weapon_damage
			bullet.range = _enemy_stats.weapon_range * 1.25
			bullet.speed = _enemy_stats.weapon_speed * 0.75
			bullet.direction = Vector2.RIGHT.rotated(TAU / NUMBER_OF_PROJECTILES * i)
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = global_position + bullet.direction * 25
		
		mild_explosion.play()
		big_laser_2.play()
		
		await get_tree().create_timer(0.1).timeout
		
		for i in NUMBER_OF_PROJECTILES:
			var bullet = BULLET.instantiate()
			bullet.damage = _enemy_stats.weapon_damage
			bullet.range = _enemy_stats.weapon_range * 1.25
			bullet.speed = _enemy_stats.weapon_speed * 0.75
			bullet.direction = Vector2.RIGHT.rotated(TAU / NUMBER_OF_PROJECTILES * i + TAU / NUMBER_OF_PROJECTILES / 2)
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = global_position + bullet.direction * 25
		
		await get_tree().create_timer(0.1).timeout
		
		for i in NUMBER_OF_PROJECTILES:
			var bullet = BULLET.instantiate()
			bullet.damage = _enemy_stats.weapon_damage
			bullet.range = _enemy_stats.weapon_range * 1.25
			bullet.speed = _enemy_stats.weapon_speed * 0.75
			bullet.direction = Vector2.RIGHT.rotated(TAU / NUMBER_OF_PROJECTILES * i)
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = global_position + bullet.direction * 25

func _on_big_laser_2_finished():
	queue_free()
