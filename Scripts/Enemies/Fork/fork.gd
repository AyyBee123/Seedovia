extends "res://Scripts/Enemies/enemy.gd"

@onready var cooldown = $Cooldown
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var thud_SFX = $Thud2
@onready var stomp_SFX = $Stomp
@onready var quiet_thud_SFX = $QuietThud

const ENEMY_EXPLOSION = preload("res://Scenes/Enemies/Weapons/Enemy Explosion.tscn")
const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const NUMBER_OF_LOOPS = 2 # number of times the slam animation loops after the first
const SLAM_SPEED_MULTIPLIER = 2

var current_loop: int = 0
var original_speed

func _ready():
	randomize()
	super._ready()
	original_speed = _enemy_stats.speed

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		velocity = _enemy_stats.speed * global_position.direction_to(player.global_position)
	
	if animated_sprite_2d.animation == "Idle":
		_enemy_stats.speed = original_speed
	elif animated_sprite_2d.animation == "Slam":
		_enemy_stats.speed = original_speed * SLAM_SPEED_MULTIPLIER
	
	move_and_slide()

func _on_cooldown_timeout():
	animated_sprite_2d.play("Slam")

func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == "Slam":
		Targets.get_camera().add_trauma(0.2)
		
		thud_SFX.play()
		stomp_SFX.play()
		quiet_thud_SFX.play()
		
		var NUMBER_OF_BULLETS = randf_range(4, 6)
		for i in NUMBER_OF_BULLETS:
			var bullet = BULLET.instantiate()
			bullet.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
			bullet.damage = _enemy_stats.weapon_damage
			bullet.speed = _enemy_stats.weapon_speed * randf_range(0.75, 1.25)
			bullet.range = _enemy_stats.weapon_range * randf_range(0.75, 1.25)
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = $Shadow.global_position
		
		var exp = ENEMY_EXPLOSION.instantiate()
		exp.damage = _enemy_stats.weapon_damage
		exp.size = 0.8
		exp.modulate = "FF0000"
		exp.z_index = 0
		get_tree().current_scene.add_child.call_deferred(exp)
		exp.global_position = $Shadow.global_position
		
		if current_loop >= NUMBER_OF_LOOPS:
			current_loop = 0
			animated_sprite_2d.play("Idle")
		else:
			current_loop += 1
			cooldown.start()
