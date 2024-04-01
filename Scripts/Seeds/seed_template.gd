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

func _ready():
	pass

func _physics_process(delta):
	initialize_position()
	travelled_distance()
	distance_after_collision()
	update_position(delta)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		if slot_index == 0:
			direction = global_position.direction_to(get_global_mouse_position())
		else:
			direction = desired_direction.normalized()
		position_initialized = true

func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		call_deferred("free")

func distance_after_collision():
	short_distance_travelled = starting_position.distance_to(self.global_position)
	if short_distance_travelled >= 1:
		ignore_first_collision = false

func _on_hitbox_area_entered(area):
	_collide(area)

func _on_hitbox_body_entered(body):
	_collide(body)

func _collide(body):
	if not ignore_first_collision:
		has_collided.emit(body)
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
		call_deferred("free")
	else:
		ignore_first_collision = false

func shoot_next_weapon(weapon):
	var weapon_instance = weapon.instantiate()
	get_weapon_properties(weapon_instance, weapon_direction)

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
	call_deferred("initialize_location", weapon)

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon.global_position = global_position
	weapon_fired.emit(weapon)

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta
	look_at(global_position + current_velocity)
