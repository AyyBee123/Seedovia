extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var lifetime = $Lifetime
@onready var bubble_fire = $BubbleFire
@onready var bubble_pop = $BubblePop

var spread: float
var size: float
var acceleration: float
var decel_threshold = 0.05

func _ready():
	bubble_fire.play()
	super._ready()
	spread = deg_to_rad(randf_range(-30,30)) # random 30 degree spread
	size = randf_range(0.8, 1) # random sizes to immitate how bubbles work irl
	scale = Vector2.ONE * size
	acceleration = randf_range(0.75, 1) * _player_stats.get_stat("Weapon_Range") / 100
	deceleration.start(acceleration)

func update_position(delta):
	if deceleration.time_left > decel_threshold:
		current_velocity = direction.rotated(spread) * _player_stats.get_stat("Weapon_Speed")\
		* speed_multiplier * deceleration.time_left
	else:
		current_velocity = direction.rotated(spread) * _player_stats.get_stat("Weapon_Speed")\
		* speed_multiplier * decel_threshold
	position += current_velocity * delta

func _on_deceleration_timeout():
	lifetime.start()

func _on_lifetime_timeout():
	_collide.call_deferred(null)

func travelled_distance():
	pass

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	bubble_pop.play()
	if body != null:
		has_collided.emit(body)
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	weapon_direction = direction.rotated(spread)
	shoot_next_weapon()
	# wait for the pop sound to play so it doesn't get cut off by the queue_free function
	await bubble_pop.finished
	queue_free.call_deferred()

func shoot_next_weapon():
	if not randf() < 0.5:
		return
	super.shoot_next_weapon()
