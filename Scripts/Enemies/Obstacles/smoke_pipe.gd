extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var pos = $Marker2D
@onready var fire_rate = $"Fire Rate"

const SMOKE_BULLET = preload("res://Scenes/Enemies/Weapons/Smoke Bullet.tscn")

const SPREAD = PI/12
var SPEED_OFFSET = 50

func _ready():
	randomize()
	super._ready()

func _on_fire_rate_timeout():
	var bullet = SMOKE_BULLET.instantiate()
	bullet.direction = global_position.direction_to(pos.global_position).normalized().rotated(randf_range(-SPREAD, SPREAD))
	bullet.damage = _enemy_stats.weapon_damage
	bullet.range = _enemy_stats.weapon_range
	bullet.speed = _enemy_stats.weapon_speed + randf_range(-SPEED_OFFSET, SPEED_OFFSET)
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = pos.global_position
	fire_rate.start()
