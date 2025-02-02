extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var deceleration = $"Deceleration"
@onready var lifetime = $Lifetime

var max_range_reached := false
var decelerating := false
var lifetime_amount = 0

func _ready():
	super._ready()
	rotation = randf_range(0, TAU)
	if lifetime_amount <= 0:
		lifetime_amount = lifetime.wait_time
	lifetime.start(lifetime_amount)

func update_position(delta):
	var current_velocity: Vector2
	if max_range_reached:
		current_velocity = direction * max(speed * deceleration.time_left / deceleration.wait_time, 10)
	else:
		current_velocity = direction * speed
	position += current_velocity * delta

func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= range:
		max_range_reached = true
		if not decelerating:
			deceleration.start()
			decelerating = true

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(damage)
	# if the bullet hits anything else (i.e. a wall)
	else:
		queue_free()

func _on_lifetime_timeout():
	queue_free()
