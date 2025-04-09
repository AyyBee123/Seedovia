extends AnimatedSprite2D

@onready var pancake_detect = $"Pancake Detect"

var damage: int = 1
var range: float = 0
var speed: float = 0

var direction: Vector2

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet
var position_initialized := false
var player
var ignore_first_collision := false # this lets the projectiles spawn without instantly colliding with an object

var source
var returned: bool

func _ready():
	starting_position = global_position

func _physics_process(delta):
	if not is_instance_valid(source):
		queue_free()
		return
	initialize_position()
	travelled_distance()
	update_position(delta)
	set_ignore_first_collision()
	
	if returned:
		direction = global_position.direction_to(source.marker.global_position)

func _on_bullet_hitbox_body_entered(body):
	_collide(body)

func _on_bullet_hitbox_area_entered(area):
	_collide(area)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		position_initialized = true

func set_ignore_first_collision():
	await get_tree().create_timer(0.05).timeout
	ignore_first_collision = false

func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= range:
		return_pancake()

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
	return_pancake()

func return_pancake():
	if returned:
		return
	returned = true

func destroy():
	source.projectile_count += 1
	queue_free()

func _on_pancake_detect_area_entered(area):
	if returned and area.get_parent() == source:
		destroy()
