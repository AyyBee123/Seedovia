extends Sprite2D

var position_initialized = false
var direction
var starting_position: Vector2 # gets the starting position from where the bullet is fired
var object
var damage: float
var explosion_size: float
var spread: float
var speed: float
var weapon_direction: Vector2
var parent_banana

signal weapon_fired(weapon)
signal has_collided(object)
signal attempted_fire

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats
@onready var projectile_speed_timer := $"Projectile Deceleration"
@onready var life_time := $Lifetime
@onready var resource_preloader := $ResourcePreloader

func _physics_process(delta):
	initialize_position()
	update_position(delta)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		position_initialized = true

func banana():
	pass

func update_position(delta):
	var current_velocity: Vector2 = direction * speed * projectile_speed_timer.time_left
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func _on_enemy_detect_area_entered(area):
	explode()
	
func _on_wall_detect_body_entered(body):
	has_collided.emit(body)
	explode()

func _on_lifetime_timeout():
	explode()
	
func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = damage
	explosion.size = explosion_size
	explosion.source = self
	explosion.modulate = Color.YELLOW
	for passive in $Passives.get_children():
		if passive.name == "ExplosiveTrigger":
			continue
		if passive.name == "HuraCrepitans":
			continue
		explosion.get_node("Passives").add_child(passive.duplicate())
	call_deferred("create_child", explosion)
	queue_free()
	
func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
	weapon_direction = direction
	attempted_fire.emit(child)
	weapon_fired.emit(child)
