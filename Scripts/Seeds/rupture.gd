extends Sprite2D

signal weapon_fired(weapon)
signal has_collided(object)
signal attempted_fire

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats
@onready var seed_slots := $"../Player/Inventory/Inventory Screen/Seed Slots".get_children()
@onready var noise_SFX = $Noise

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
@onready var fire_rate = $"Fire Rate"
@onready var detect_ruptures = $"Detect Ruptures"
@onready var bottom_left = $"Bottom Left"
@onready var bottom_right = $"Bottom Right"
@onready var top_left = $"Top Left"
@onready var top_right = $"Top Right"

var is_in_area := false
var enemy = null
var mouse_left_down := true
var x_pos: float
var lifetime_started := false
var is_shrinking := false
var SFX_is_playing := false

func _ready():
	visible = false
	middle.scale.y = max(0, _player_stats.get_stat("Weapon_Range")) # extends the beam length based on player range
	top.position.y -= middle.scale.y - 1 # places the top portion of the beam above the middle portion
	collision_shape_2d.shape.extents.y = 20 + middle.scale.y * 0.5
	collision_shape_2d.position.y = -16 - middle.scale.y * 0.5
	collision_shape_2d.disabled = true
	top_left.position.y = -32 - middle.scale.y
	top_right.position.y = top_left.position.y
	x_pos = 1

func _physics_process(delta):
	initialize_position()
	travelled_distance()
	update_position(delta)
	if slot_index > 0:
		noise_SFX.volume_db = max(noise_SFX.volume_db - delta * 10, linear_to_db(0))
	if is_in_area:
		if tick_rate.is_stopped():
			enemy._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
			has_collided.emit(enemy.get_node("Enemy Hitbox"))
			tick_rate.start(0.1 / _player_stats.get_stat("Fire_Rate") * 10)
	if slot_index == 0: # if fired from the player
		if not mouse_left_down:
			is_shrinking = true
	if is_shrinking:
		shrink(65)

func rupture(): # this is just to find other ruptures that exist using the has_method function (a.k.a duck typing)
	pass

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		direction = desired_direction.normalized()
		position_initialized = true
		if slot_index == 0:
			rotation = global_position.angle_to_point(player.weapon_direction_marker.global_position) + deg_to_rad(90)
		else:
			rotation = desired_direction.angle() + deg_to_rad(90)
		# if the seed is the first seed (shot directly by the player character)
		if slot_index == 0:
			# only the first instance of a node has its original name
			# other instances will just be Node<Object Type>
			# this removes all rupture nodes after the first, until the original is destroyed, then the cycle repeats
			if not name == "Rupture":
				queue_free()
		else:
			var areas = detect_ruptures.get_overlapping_areas()
			for area in areas:
				if abs(area.get_parent().rotation - rotation) <= deg_to_rad(1) \
						and area.get_parent().global_position.distance_to(global_position) <= 15:
					queue_free()
					return
		visible = true
		collision_shape_2d.disabled = false
		SfxDeconflicter.play(noise_SFX)

func travelled_distance():
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

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	x_pos = -x_pos # alternate direction of the next weapon
	weapon_direction = Vector2.RIGHT.rotated(rotation + randf_range(deg_to_rad(-5), deg_to_rad(5))) * sign(x_pos)
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
	if x_pos < 0:
		weapon.global_position = Vector2(randf_range(bottom_left.global_position.x,top_left.global_position.x),\
		randf_range(bottom_left.global_position.y,top_left.global_position.y))
	else:
		weapon.global_position = Vector2(randf_range(bottom_right.global_position.x,top_right.global_position.x),\
		randf_range(bottom_right.global_position.y,top_right.global_position.y))
	weapon_fired.emit(weapon)

func update_position(delta):
	if slot_index == 0:
		global_position = player.hand.global_position
		rotation = global_position.angle_to_point(player.weapon_direction_marker.global_position) + deg_to_rad(90)
	else:
		if previous_weapon != null:
			global_position = previous_weapon.global_position
			rotation = desired_direction.angle() + deg_to_rad(90)
		else:
			if not lifetime_started:
				lifetime.start()
				lifetime_started = true

func _input(event):
	if Input.is_action_just_pressed("shoot") and event.is_pressed():
			mouse_left_down = true
	elif Input.is_action_just_released("shoot") and not event.is_pressed():
			mouse_left_down = false

func shrink(shrink_speed_mult):
	bottom.scale.x -= get_process_delta_time() * shrink_speed_mult
	middle.scale.x -= get_process_delta_time() * shrink_speed_mult
	top.scale.x -= get_process_delta_time() * shrink_speed_mult
	noise_SFX.volume_db -= get_process_delta_time() * shrink_speed_mult * 10
	if middle.scale.x <= 0:
		queue_free.call_deferred()

func _on_lifetime_timeout():
	is_shrinking = true

func _on_fire_rate_timeout():
	shoot_next_weapon()
	fire_rate.start()

func get_next_weapon():
	return null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 else\
	PlayerSeeds.seeds[slot_index + 1]
