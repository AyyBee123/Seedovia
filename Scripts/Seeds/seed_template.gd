extends Sprite2D

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall

@onready var player = Targets.get_player()
var _player_stats
var source # original source of the seed (player or an enemy)

# base stats of the seed
@export var BASE_DAMAGE: float
@export var BASE_FIRE_RATE: float
@export var BASE_RANGE: float
@export var BASE_SPEED: float
@export var BASE_SIZE: float
@export var BASE_BLAST_RADIUS: float

var weapon_direction: Vector2 # the direction the weapon goes, based on the previous weapon/player
var desired_direction: Vector2 # the direction the weapon wants the next weapon to go
var hit_enemy = null # sometimes, the weapon wants information on the enemy it collided with
var target_group := "Enemies" # check the target group to damage (can be Enemies or Players)
var collisions = 5 # the collision masks that should be detected by the seed
var shader # shader for the seed (mainly for enemies)

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet
var total_distance := 0.0 # distance travelled (this is used for the weapon's range)

var initial_weapon := false # checks if the weapon is the first in slot (was directly fired by the player)
var ignore_first_collision := false # this lets the projectiles spawn without instantly colliding with an object
var short_distance_travelled: float # this lets the projectile move a little before enabling collisions again
var previous_weapon # this is used for weapons that persist and move as they're spawning the next weapon
var next_weapon_pos: Vector2: get = get_next_weapon_pos # get the next weapon's position

# these are declared in the player script (for the first weapon) and then passed over from weapon to weapon
var slot_index: int # the index to determine the order the weapon is fired (set to 2 to not fire next seed)
var seed_slot_number: int # determines which slot the weapon is in, in the inventory
var set_next_seed_slot_number = null # set the next seed's slot number before firing it
var set_next_seed_slot_index = null # set the next seed's slot index before firing it

var direction: Vector2 # the current direction the weapon is moving towards
var current_velocity: Vector2 # the current speed/velocity the weapon is moving at
var next_weapon = null # setting the next seed from an external source

var damage_color # the displayed damage color
var damage_size # the displayed damage size

var DAMAGE: float:
	get:
		if _player_stats:
			return BASE_DAMAGE * (1 + _player_stats.stats["Weapon_Damage"]["+"]) \
					* _player_stats.stats["Weapon_Damage"]["x"] * transferred_damage_multiplier
		else:
			return BASE_DAMAGE * transferred_damage_multiplier
var FIRE_RATE: float:
	get:
		if _player_stats:
			return BASE_FIRE_RATE * (1 + _player_stats.stats["Fire_Rate"]["+"]) \
					* _player_stats.stats["Fire_Rate"]["x"] * transferred_fire_rate_multiplier
		else:
			return BASE_FIRE_RATE * transferred_fire_rate_multiplier
var RANGE: float:
	get:
		if _player_stats:
			return BASE_RANGE * (1 + _player_stats.stats["Weapon_Range"]["+"]) \
					* _player_stats.stats["Weapon_Range"]["x"] * transferred_range_multiplier
		else:
			return BASE_RANGE * transferred_range_multiplier
var SPEED: float:
	get:
		if _player_stats:
			return BASE_SPEED * (1 + _player_stats.stats["Weapon_Speed"]["+"]) \
					* _player_stats.stats["Weapon_Speed"]["x"] * transferred_speed_multiplier
		else:
			return BASE_SPEED * transferred_speed_multiplier
var SIZE: float:
	get:
		if _player_stats:
			return BASE_SIZE * (1 + _player_stats.stats["Weapon_Size"]["+"]) \
					* _player_stats.stats["Weapon_Size"]["x"] * transferred_size_multiplier
		else:
			return BASE_SIZE * transferred_size_multiplier
var BLAST_RADIUS: float:
	get:
		if _player_stats:
			return BASE_BLAST_RADIUS * (1 + _player_stats.stats["Weapon_Blast_Radius"]["+"]) \
					* _player_stats.stats["Weapon_Blast_Radius"]["x"] * transferred_blast_radius_multiplier
		else:
			return BASE_BLAST_RADIUS * transferred_blast_radius_multiplier

# multipliers transferred from an external source, like passive effects that shoot a seed
var transferred_speed_multiplier: float = 1 # shot speed multiplier of the weapon
var transferred_range_multiplier: float = 1 # range multiplier of the weapon before it gets destroyed
var transferred_size_multiplier: float = 1 # size multiplier of the weapon
var transferred_damage_multiplier: float = 1 # damage multiplier of the weapon
var transferred_blast_radius_multiplier: float = 1 # blast/splash radius multiplier of the weapon
var transferred_fire_rate_multiplier: float = 1 # fire rate multiplier of the weapon

var seed_pool: Array = [] # pool to add the next seed to

func _ready():
	_player_stats = player._player_stats
	visible = false # avoid "jitter" on the very first frame
	$Hitbox.set_collision_mask(collisions)
	scale = scale * SIZE
	direction = desired_direction.normalized()
	if shader:
		material = ShaderMaterial.new()
		material.shader = shader
		for i in get_children():
			if i.name == "Shadow":
				continue
			if i is Sprite2D or i is AnimatedSprite2D:
				i.material = ShaderMaterial.new()
				i.material.shader = shader
	await get_tree().physics_frame
	visible = true
	starting_position = global_position

func _physics_process(delta):
	player = Targets.get_player()
	_player_stats = player._player_stats
	travelled_distance()
	update_position(delta)
	set_ignore_first_collision()
	visible = true

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		queue_free.call_deferred()

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
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	queue_free.call_deferred()

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction)

func set_weapon_properties(weapon, _desired_direction, _ignore_first_collision = false, _enemy = null):
	weapon.initial_weapon = false
	weapon.ignore_first_collision = _ignore_first_collision
	weapon.desired_direction = _desired_direction
	weapon.previous_weapon = self
	weapon.source = source
	weapon.hit_enemy = _enemy
	if set_next_seed_slot_index:
		weapon.slot_index = set_next_seed_slot_index
	else:
		weapon.slot_index = slot_index + 1
	weapon.transferred_speed_multiplier *= transferred_speed_multiplier
	weapon.transferred_range_multiplier *= transferred_range_multiplier
	weapon.transferred_size_multiplier *= transferred_size_multiplier
	weapon.transferred_damage_multiplier *= transferred_damage_multiplier
	weapon.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
	weapon.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
	if set_next_seed_slot_number:
		weapon.seed_slot_number = set_next_seed_slot_number
	else:
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
	current_velocity = direction * SPEED
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func get_next_weapon():
	if next_weapon:
		return next_weapon
	return null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 \
			else PlayerSeeds.seeds[slot_index + 1]

func set_next_weapon(_weapon):
	next_weapon = _weapon

func set_ignore_first_collision():
	await get_tree().create_timer(0.05).timeout
	ignore_first_collision = false

func get_next_weapon_pos():
	return global_position
