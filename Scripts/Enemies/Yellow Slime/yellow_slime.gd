extends "res://Scripts/Enemies/enemy.gd"

@onready var hitbox := $"Enemy Hitbox"
@onready var initial_collision_mask: int = $"Enemy Hitbox".get_collision_mask()
@onready var initial_collision_layer: int = $"Enemy Hitbox".get_collision_layer()
@onready var fire_time := $"Fire Time"

var bullet = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")
var number_of_shots := 3

func _ready():
	super._ready()
	
func _physics_process(delta):
	super._physics_process(delta)
	$"Rotation Point".look_at(player.global_position)

func jump():
	var direction = player.global_position - self.global_position
	velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	hitbox.set_collision_mask(0)
	hitbox.set_collision_layer(0)

func idle():
	hitbox.set_collision_mask(initial_collision_mask)
	hitbox.set_collision_layer(initial_collision_layer)
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)

func shoot():
	var can_fire = false
	if fire_time.is_stopped():
		can_fire = true
		fire_time.start(1.0/number_of_shots)
	if can_fire:
		shoot_bullet()

func shoot_bullet():
	var bullet_instance = bullet.instantiate()
	bullet_instance.damage = _enemy_stats.weapon_damage
	bullet_instance.range = _enemy_stats.weapon_range
	bullet_instance.speed = _enemy_stats.weapon_speed
	bullet_instance.direction = global_position.direction_to(player.global_position).normalized()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = $"Rotation Point/Marker2D".global_position
	
