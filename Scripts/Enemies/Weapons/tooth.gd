extends CharacterBody2D

var damage: int = 1
var range: float = 2500
var speed: float = 250

var direction: Vector2

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var position_initialized := false
var player
var source
var total_distance = 0

func _ready():
	total_distance = 0
	position_initialized = false
	starting_position = global_position
	$CollisionShape2D.disabled = false
	$"Bullet Hitbox/CollisionShape2D".disabled = false
	look_at(global_position + direction)
	set_process(true)
	set_physics_process(true)
	show()

func _physics_process(delta):
	initialize_position()
	travelled_distance()
	update_position(delta)
	var collision = move_and_collide(velocity * delta)
	velocity = direction.normalized() * speed
	if collision:
		velocity = velocity.bounce(collision.get_normal()).normalized()
		direction = velocity

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(self)
		destroy()

func _on_bullet_hitbox_body_entered(body):
	_collide(body)

func _on_bullet_hitbox_area_entered(area):
	_collide(area)

func travelled_distance():
	total_distance += abs((starting_position - global_position).length())
	starting_position = global_position
	if total_distance >= range:
		destroy()

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		position_initialized = true

func destroy():
	if is_instance_valid(source):
		source.add_to_pool(self, source.teeth_pool)
	$CollisionShape2D.set_deferred("disabled", true)
	$"Bullet Hitbox/CollisionShape2D".set_deferred("disabled", true)
	set_process(false)
	set_physics_process(false)
	position_initialized = false
	total_distance = 0
	hide()
