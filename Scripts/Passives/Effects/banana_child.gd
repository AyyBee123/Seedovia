extends Sprite2D

var position_initialized = false
var direction
var starting_position: Vector2 # gets the starting position from where the bullet is fired

var object
var damage: float
var damage_multiplier: float
var explosion_size: float

var spread: float

var speed: float
var speed_multiplier: float

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

func update_position(delta):
	var current_velocity: Vector2 = direction * speed * speed_multiplier * projectile_speed_timer.time_left
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func _on_enemy_detect_area_entered(area):
	explode()
	
func _on_wall_detect_body_entered(body):
	explode()

func _on_lifetime_timeout():
	explode()
	
func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = damage
	explosion.damage_multiplier = damage_multiplier
	explosion.size = explosion_size
	explosion.get_node("AnimatedSprite2D").self_modulate = Color(1,1,0)
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = self.global_position
	queue_free()
