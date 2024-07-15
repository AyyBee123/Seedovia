extends Sprite2D

signal weapon_fired(weapon)
signal has_collided(object)
signal attempted_fire

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats
@onready var seed_slots := $"../Player/Inventory/Inventory Screen/Seed Slots".get_children()

var weapon_direction: Vector2 # the direction the weapon goes, based on the previous weapon/player
var desired_direction: Vector2 # the direction the weapon wants the next weapon to go
var hit_enemy = null # sometimes, the weapon wants information on the enemy it collided with

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet
var total_distance := 0

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

@onready var bottom = $Bottom
@onready var middle = $Middle
@onready var top = $Top
@onready var tick_rate = $"Tick Rate"
@onready var collision_shape_2d = $Hitbox/CollisionShape2D
@onready var lifetime = $Lifetime

var is_in_area := false
var enemy = null
var mouse_left_down := true

static var rupture_spawns: Array

func _ready():
	visible = false
	rupture_spawns.append(self)
	if slot_index == 0: # if fired from the player
		if rupture_spawns.size() > 1:
			rupture_spawns[1].queue_free()
			rupture_spawns.remove_at(1) # remove any extra ruptures that spawn
			return
	else:
		lifetime.start()
	middle.scale.y = max(0, _player_stats.get_stat("Weapon_Range")) # extends the beam length based on player range
	top.position.y -= middle.scale.y - 1 # places the top portion of the beam above the middle portion
	collision_shape_2d.shape.extents.y = 32 + middle.scale.y * 0.5 - 1
	collision_shape_2d.position.y = -16 - middle.scale.y * 0.5

func _physics_process(delta):
	initialize_position()
	travelled_distance()
	distance_after_collision()
	update_position(delta)
	if is_in_area:
		if tick_rate.is_stopped():
			enemy._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
			has_collided.emit(enemy.get_node("Enemy Hitbox"))
			tick_rate.start(0.1 / _player_stats.get_stat("Fire_Rate") * 10)
	if slot_index == 0: # if fired from the player
		if not mouse_left_down:
			rupture_spawns.remove_at(0)
			queue_free()
	else:
		if lifetime.is_stopped():
			rupture_spawns.remove_at(0)
			queue_free()

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		direction = desired_direction.normalized()
		position_initialized = true
		if slot_index == 0:
			rotation = global_position.angle_to_point(get_global_mouse_position()) + deg_to_rad(90)
		else:
			rotation = desired_direction.angle() + deg_to_rad(90)
		visible = true

func travelled_distance():
	pass

func distance_after_collision():
	pass

func _on_hitbox_area_entered(area):
	_collide(area)

func _on_hitbox_body_entered(body):
	_collide(body)

func _collide(body):
	if body.is_in_group("Enemies"):
		enemy = body.get_parent()
		is_in_area = true

func _on_hitbox_area_exited(area):
	if area.is_in_group("Enemies"):
		is_in_area = false

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
	initialize_location.call_deferred(weapon)

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	weapon.global_position = global_position

func update_position(delta):
	if slot_index == 0:
		global_position = player.hand.global_position
		rotation = global_position.angle_to_point(get_global_mouse_position()) + deg_to_rad(90)
	else:
		if previous_weapon != null:
			global_position = previous_weapon.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				mouse_left_down = true
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
				mouse_left_down = false
