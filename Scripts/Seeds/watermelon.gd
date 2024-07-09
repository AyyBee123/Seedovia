extends Sprite2D

signal weapon_fired(weapon)
signal has_collided(object)
signal attempted_fire

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats
@onready var seed_slots := $"../Player/Inventory/Inventory Screen/Seed Slots".get_children()

var weapon_direction: Vector2
var desired_direction: Vector2
var hit_enemy = null

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet
var total_distance = 0

# this value is set because the weapon's position is not updated until after the ready function.
# That's why it's called in the physics process function instead of the ready function
var position_initialized := false

var initial_weapon := false
var ignore_first_collision := false # this lets the projectiles spawn without instantly colliding with an object
var short_distance_travelled: float # this lets the projectile move a little before enabling collisions again
var previous_weapon = null # this is used for weapons that persist and move as they're spawning the next weapon

# these are declared in the player script (for the first weapon) and then passed over from weapon to weapon
var slot_index: int # the index to determine the order the weapon is fired
var seed_slot_number: int # determines which slot the weapon is in, in the inventory

var direction: Vector2
var current_velocity: Vector2

# initialize multipliers
@export var speed_multiplier: float = 1 # shot speed multiplier of the weapon
@export var range_multiplier: float = 1 # range multiplier of the weapon before it gets destroyed
@export var size_multiplier: float = 1 # size multiplier of the weapon
@export var damage_multiplier: float = 1 # damage multiplier of the weapon
@export var blast_radius_multiplier: float = 1 # blast/splash radius multiplier of the weapon
@export var fire_rate_multiplier: float = 1 # fire rate multiplier of the weapon

@onready var down = $Down
@onready var up = $Up
@onready var left = $Left
@onready var right = $Right
@onready var resource_preloader = $ResourcePreloader

var area_normal # gets the normal of the collsion area/wall

func _ready():
	area_normal = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _physics_process(delta):
	rotation = 0 # locks the rotation of the parent node (to prevent shapecasts from rotating)
	initialize_position()
	travelled_distance()
	distance_after_collision()
	update_position(delta)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		direction = desired_direction.normalized()
		position_initialized = true

func travelled_distance():
	# make it so a counter goes up by one for every unit the vector changes by (maybe magnitude to get distance)
	distance_travelled = starting_position.distance_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
	if total_distance >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		call_deferred("free")

func distance_after_collision():
	short_distance_travelled = starting_position.distance_to(global_position)
	if short_distance_travelled >= 1:
		ignore_first_collision = false

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta
	$AnimatedSprite2D.look_at(global_position + current_velocity)

func _on_hitbox_area_entered(area):
	if area.is_in_group("Enemies"):
		# shapecasts allow the projectile to bounce after detecting an enemy
		area_normal = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() # just in case
		if down.is_colliding():
			area_normal = Vector2(0, -1)
		elif up.is_colliding():
			area_normal = Vector2(0, 1)
		elif left.is_colliding():
			area_normal = Vector2(1, 0)
		elif right.is_colliding():
			area_normal = Vector2(-1, 0)
		direction = direction.bounce(area_normal).normalized()
		area.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
		collide(area)

func _on_hitbox_body_entered(body):
	# shapecasts allow the projectile to bounce after detecting a wall
	area_normal = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() # just in case
	if down.is_colliding():
		area_normal = Vector2(0, -1)
	elif up.is_colliding():
		area_normal = Vector2(0, 1)
	elif left.is_colliding():
		area_normal = Vector2(1, 0)
	elif right.is_colliding():
		area_normal = Vector2(-1, 0)
	direction = direction.bounce(area_normal).normalized()
	collide(body)

func collide(area):
	if ignore_first_collision:
		return
	if area != null:
		has_collided.emit(area)
	explode()
	attempted_fire.emit()
	var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2\
	else PlayerSeeds.seeds[slot_index + 1]
	if weapon != null:
		shoot_next_weapon(weapon)

func shoot_next_weapon(weapon):
	var weapon_instance = weapon.instantiate()
	get_weapon_properties(weapon_instance, area_normal, true)

func get_weapon_properties(weapon, _desired_direction, _ignore_first_collision = false, _enemy = null):
	weapon.initial_weapon = false
	weapon.ignore_first_collision = _ignore_first_collision
	weapon.desired_direction = _desired_direction
	weapon.previous_weapon = self
	weapon.hit_enemy = _enemy
	weapon.slot_index = slot_index + 1
	if seed_slot_number < 2:
		weapon.seed_slot_number = PlayerSeeds.seed_indices[slot_index + 1]
	else:
		weapon.seed_slot_number = 3
	initialize_location.call_deferred(weapon)

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	weapon.global_position = global_position

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = _player_stats.get_stat("Weapon_Damage") * damage_multiplier * 0.25
	explosion.size = _player_stats.get_stat("Weapon_Blast_Radius") * blast_radius_multiplier
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.INDIAN_RED
	create_explosion.call_deferred(explosion)

func create_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
