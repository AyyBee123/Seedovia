extends Sprite2D

var position_initialized = false
var direction
var starting_position: Vector2 # gets the starting position from where the bullet is fired
var damage: float
var explosion_size: float
var spread: float
var speed: float
var weapon_direction: Vector2
var source_pos

@onready var projectile_speed_timer := $"Projectile Deceleration"
@onready var life_time := $Lifetime
@onready var resource_preloader := $ResourcePreloader

func _ready():
	global_position = source_pos
	spread = deg_to_rad(randf_range(-20,20))

func _physics_process(delta):
	initialize_position()
	direction = weapon_direction.normalized().rotated(spread)
	update_position(delta)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		position_initialized = true

func update_position(delta):
	var current_velocity: Vector2 = direction * speed * projectile_speed_timer.time_left
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
	explosion.size = explosion_size
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.YELLOW
	call_deferred("create_child", explosion)
	spawn_child_bananas()
	queue_free.call_deferred()

func spawn_child_bananas():
	# split the banana mine into 3 smaller bananas with the indicated launch directions
	var directions = [Vector2.UP, Vector2(-sqrt(3)/2,0.5), Vector2(sqrt(3)/2,0.5)]
	var spread = deg_to_rad(randf_range(-45, 45))
	for direction in directions:
		var banana_child = resource_preloader.get_resource("Banana Child").instantiate()
		banana_child.damage = damage * 0.35
		banana_child.speed = speed
		banana_child.explosion_size = 0.65
		banana_child.direction = direction.rotated(spread)
		call_deferred("create_child", banana_child)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
