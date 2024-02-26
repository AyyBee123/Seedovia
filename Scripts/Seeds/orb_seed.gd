extends CharacterBody2D

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats
@onready var seed_slots := $"../Player/Inventory/NinePatchRect/Seed Slots".get_children()
@onready var orb_fire_rate := $"Fire Rate"

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet

# this value is set because the weapon's position is not updated until after the ready function.
# That's why it's called in the physics process function instead of the ready function
var position_initialized := false

var initial_weapon := true
var ignore_first_collision := false # this is to let the projectiles spawn without instantly colliding with an object
var short_distance_travelled: float # this lets the projectile move a little before enabling collisions again

var slot_index: int

var shot_direction := Vector2(0,-1)

# initialize multipliers
@export var speed_multiplier: float = 1 # shot speed multiplier of the weapon
@export var range_multiplier: float = 1 # range multiplier of the weapon before it gets destroyed
@export var size_multiplier: float = 1 # size multiplier of the weapon
@export var damage_multiplier: float = 1 # damage multiplier of the weapon
@export var blast_radius_multiplier: float = 1 # blast/splash radius multiplier of the weapon
@export var fire_rate_multiplier: float = 1 # fire rate multiplier of the weapon

func _ready():
	orb_fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * fire_rate_multiplier)
	orb_fire_rate.start()

func _physics_process(delta):
	initialize_position()
	collision_detect(delta)
	travelled_distance()
	distance_after_collision()
	for i in range(seed_slots.size()):
		var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
		if weapon != null:
			if orb_fire_rate.is_stopped():
				shoot_next_weapon(weapon)
			break

func _on_bullet_hitbox_body_entered(body):
	_collide(body)
	
func _on_bullet_hitbox_area_entered(area):
	_collide(area)
	
func _collide(body):
	if not ignore_first_collision:
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
		queue_free()
	else:
		ignore_first_collision = false
	
func shoot_next_weapon(weapon):
	var weapon_instance = weapon.instantiate()
	weapon_instance.initial_weapon = false
	weapon_instance.ignore_first_collision = true
	weapon_instance.slot_index = slot_index + 1
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = global_position
	weapon_instance.velocity = shot_direction.normalized()
	weapon_instance.rotation = weapon_instance.velocity.angle()
	change_direction()
	orb_fire_rate.start()
	
func initialize_position():
	if not position_initialized:
		if initial_weapon:
			slot_index = 0
		starting_position = global_position
		position_initialized = true

func collision_detect(delta):
	var collision_detect = move_and_collide(velocity * delta * _player_stats.get_stat("Weapon_Speed") * speed_multiplier)
	
func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		queue_free()
		
func distance_after_collision():
	short_distance_travelled = starting_position.distance_to(self.global_position)
	if short_distance_travelled >= 1:
		ignore_first_collision = false
		
func change_direction():
	match shot_direction:
		Vector2(0,-1):
			shot_direction = Vector2(1,-1)
		Vector2(1,-1):
			shot_direction = Vector2(1,0)
		Vector2(1,0):
			shot_direction = Vector2(1,1)
		Vector2(1,1):
			shot_direction = Vector2(0,1)
		Vector2(0,1):
			shot_direction = Vector2(-1,1)
		Vector2(-1,1):
			shot_direction = Vector2(-1,0)
		Vector2(-1,0):
			shot_direction = Vector2(-1,-1)
		Vector2(-1,-1):
			shot_direction = Vector2(0,-1)
