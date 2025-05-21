extends "res://Scripts/Enemies/enemy.gd"

@onready var shadow = $Shadow
@onready var jump_SFX = $Jump
@onready var stomp_SFX = $Stomp
@onready var idle_time = $"Idle Time"
@onready var animation_player = $AnimationPlayer

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const IDLE_TIME = 1.3

var direction: Vector2

func _ready():
	super._ready()
	$"Enemy Hitbox/CollisionPolygon2D".disabled = false
	randomize()
	shadow.visible = false
	idle_time.start(randf_range(1, 2))

func _physics_process(delta):
	super._physics_process(delta)
	if animation_player.is_playing(): # if the statue is jumping
		velocity = direction * _enemy_stats.speed
	else:
		velocity = Vector2.ZERO
		direction = global_position.direction_to(player.global_position)
	
	move_and_slide()

func play_jump():
	jump_SFX.play()

func play_stomp():
	stomp_SFX.play()
	idle_time.start(IDLE_TIME)
	# spawn the bullets
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
	for dir in directions:
		var bullet = BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed
		bullet.direction = dir
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + dir * 20

func _on_idle_time_timeout():
	animation_player.play("Jump")
