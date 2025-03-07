extends AnimatedSprite2D

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall

var direction: Vector2
var damage_multiplier: float = 1
var speed_multiplier: float = 2
var range_multiplier: float = 0.25
var previous_weapon
var starting_position: Vector2
var distance_travelled: float
var total_distance: float

var DAMAGE: float
var BLAST_RADIUS: float
var FIRE_RATE: float
var RANGE: float = 250
var SIZE: float = 1
var SPEED: float = 400

func _ready():
	previous_weapon.weapon_fired.emit(self)
	starting_position = global_position
	rotation = randf_range(0, TAU)
	await get_tree().physics_frame
	starting_position = global_position

func _physics_process(delta):
	update_position(delta)
	travelled_distance()

func update_position(delta):
	var current_velocity: Vector2 = direction * SPEED * speed_multiplier # move in direction it's rotated
	position += current_velocity * delta

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		queue_free.call_deferred()

func _on_hitbox_area_entered(area):
	has_collided.emit(area)
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(DAMAGE * damage_multiplier)
	queue_free.call_deferred()

func lunacys_delight():
	pass
