extends Sprite2D

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall
signal attempted_fire # signal for attempting to fire the next seed (even if the next seed is null)

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats
@onready var seed_slots := $"../Player/Inventory/Inventory Screen/Seed Slots".get_children()

var weapon_direction: Vector2 # the direction the weapon goes, based on the previous weapon/player
var desired_direction: Vector2 # the direction the weapon wants the next weapon to go
var hit_enemy = null # sometimes, the weapon wants information on the enemy it collided with

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet
var total_distance := 0 # distance travelled (this is used for the weapon's range)

# this value is set because the weapon's position is not updated until after the ready function.
# That's why it's called in the physics process function instead of the ready function
var position_initialized := false

var initial_weapon := false # checks if the weapon is the first in slot (was directly fired by the player)
var ignore_first_collision := false # this lets the projectiles spawn without instantly colliding with an object
var short_distance_travelled: float # this lets the projectile move a little before enabling collisions again
var previous_weapon = null # this is used for weapons that persist and move as they're spawning the next weapon

# these are declared in the player script (for the first weapon) and then passed over from weapon to weapon
var slot_index: int # the index to determine the order the weapon is fired
var seed_slot_number: int # determines which slot the weapon is in, in the inventory

var direction: Vector2 # the current direction the weapon is moving towards
var current_velocity: Vector2 # the current speed/velocity the weapon is moving at

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
	update_position(delta)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		direction = desired_direction.normalized()
		position_initialized = true
		ignore_first_collision = false

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
	if total_distance >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		call_deferred("free")

func _on_hitbox_area_entered(area):
	_collide.call_deferred(area)

func _on_hitbox_body_entered(body):
	_collide.call_deferred(body)

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	queue_free.call_deferred()

func shoot_next_weapon():
	# for passives that require the weapon to not fire a seed (e.g the last seed slot fires itself again)
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	get_weapon_properties(get_next_weapon().instantiate(), weapon_direction)

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

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func get_next_weapon():
	return null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
