extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var marker_2d = $Marker2D
@onready var fire_rate = $"Fire Rate"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var thud_SFX = $Thud3

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var direction: Vector2

func _ready():
	fire_rate.wait_time = 1.0 / _enemy_stats.fire_rate
	fire_rate.start()
	direction = Vector2.RIGHT.rotated(PI/2 + rotation) # bullet direction is towards where the face is looking

func _physics_process(delta):
	super._physics_process(delta)

func _on_fire_rate_timeout():
	animated_sprite_2d.play("Shoot")

func _on_animated_sprite_2d_animation_finished():
	var bullet = BULLET.instantiate()
	bullet.direction = direction
	bullet.speed = _enemy_stats.weapon_speed
	bullet.range = _enemy_stats.weapon_range
	bullet.damage = _enemy_stats.weapon_damage
	bullet.ignore_first_collision = true
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = $Marker2D.global_position
	fire_rate.start()
	animated_sprite_2d.play("Idle")
	SfxDeconflicter.play(thud_SFX)
