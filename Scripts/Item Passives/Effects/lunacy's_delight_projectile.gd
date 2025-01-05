extends AnimatedSprite2D

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall
signal attempted_fire # signal for attempting to fire the next seed (even if the next seed is null)

var direction: Vector2
var damage: float
var damage_multiplier: float = 1
var speed: float
var speed_multiplier: float = 2
var range: float
var range_multiplier: float = 0.25
var previous_weapon
var starting_position: Vector2
var distance_travelled: float
var total_distance: float

func _ready():
	previous_weapon.weapon_fired.emit(self)
	starting_position = global_position
	rotation = randf_range(0, TAU)

func _physics_process(delta):
	update_position(delta)
	travelled_distance()

func update_position(delta):
	var current_velocity: Vector2 = direction * speed * speed_multiplier # move in direction it's rotated
	position += current_velocity * delta

func travelled_distance():
	distance_travelled = starting_position.distance_squared_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
	if total_distance >= range * range_multiplier:
		queue_free.call_deferred()

func _on_hitbox_area_entered(area):
	has_collided.emit(area)
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(damage * damage_multiplier)
	queue_free.call_deferred()
