extends Sprite2D

var damage: int = 1
var range: float = 0
var speed: float = 0

var direction: Vector2

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet
var position_initialized := false
var player

func _ready():
	starting_position = global_position

func _physics_process(delta):
	initialize_position()
	travelled_distance()
	update_position(delta)

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
	queue_free()

func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= range:
		queue_free()

func _on_bullet_hitbox_body_entered(body):
	_collide(body)

func _on_bullet_hitbox_area_entered(area):
	_collide(area)

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		position_initialized = true
