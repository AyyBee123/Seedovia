extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var marker = $Marker2D
@onready var fire_rate = $"Fire Rate"
@onready var enemy_list: Array = Targets.get_enemies()

@export var enemy_number: int = 0
@export_range(0, 360) var starting_angle: float = 0

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var target
var radius: float = 65
var angle = 0

func _ready():
	super._ready()
	enemy_number = min(enemy_number, enemy_list.size() - 1)
	target = enemy_list[enemy_number]
	z_index = target.z_index

func _physics_process(delta):
	super._physics_process(delta)
	
	if not is_instance_valid(target):
		queue_free()
	
	if is_instance_valid(target):
		angle += delta
		global_position = Vector2(
			sin(angle * _enemy_stats.speed + deg_to_rad(starting_angle)) * radius,
			cos(angle * _enemy_stats.speed + deg_to_rad(starting_angle)) * radius
		) + target.global_position

func _on_fire_rate_timeout():
	for i in 4:
		var bullet = BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.speed = _enemy_stats.weapon_speed
		bullet.range = _enemy_stats.weapon_range
		bullet.direction = Vector2.RIGHT.rotated(PI/2 * i)
		get_tree().current_scene.add_child.call_deferred(bullet)
		bullet.global_position = marker.global_position
	fire_rate.start()
