extends CharacterBody2D

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

func _physics_process(delta):
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

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	weapon.global_position = global_position

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier * 0.0075
	move_and_collide(current_velocity)
	look_at(global_position + current_velocity)
