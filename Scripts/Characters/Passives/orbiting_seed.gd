extends Node2D

@onready var fire_rate = $"Fire Rate"

const ORBITING_SEED_ORBITAL = preload("res://Scenes/Passives/Effects/Orbiting Seed Orbital.tscn")

const RADIUS = 65
const RADIUS_MULTIPLIER = 3
const SPEED_MULTIPLIER = 2
const FIRE_RATE_MULTIPLIER = 1.5
var LERP_AMOUNT = 0.05

var seed
var player
var radius = RADIUS
var angle: float
var weapon_instance
var FIRE_RATE := 2.0
var SPEED := 100.0
var speed: float
var firing: bool
var t: float
var list: Array

func _ready():
	player = get_parent().get_parent().get_parent()
	set_item()
	var _player = Targets.get_player()
	SPEED = 200.0 * (1 + _player._player_stats.stats["Weapon_Speed"]["+"]) \
			* _player._player_stats.stats["Weapon_Speed"]["x"] / 100.0

func _physics_process(delta):
	# orbit around the player
	angle += delta * speed
	global_position = Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	) + player.global_position
	
	if firing:
		t += delta * LERP_AMOUNT
		radius = lerpf(radius, RADIUS * RADIUS_MULTIPLIER, t)
		speed = lerpf(speed, SPEED * SPEED_MULTIPLIER, t)
	else:
		t += delta * LERP_AMOUNT
		radius = lerpf(radius, RADIUS, t)
		speed = lerpf(speed, SPEED, t)
	
	if list.size() == 0:
		if fire_rate.is_stopped():
			fire_rate.start(1.0 / max(FIRE_RATE * FIRE_RATE_MULTIPLIER, 1))

func _input(event):
	if Input.is_action_just_pressed("shoot") and event.is_pressed():
			firing = true
			t = 0
	elif Input.is_action_just_released("shoot") and not event.is_pressed():
			firing = false
			t = 0

func set_item():
	seed = null if PlayerInventory.seeds.size() == 0 else PlayerSeeds.load_weapons()[0]
	if seed == null:
		return
	weapon_instance = seed.instantiate()
	weapon_instance.initial_weapon = true
	weapon_instance.slot_index = 0
	weapon_instance.previous_weapon = player
	weapon_instance.seed_slot_number = PlayerSeeds.seed_indices[0]
	weapon_instance.desired_direction = player.global_position.direction_to(global_position)
	weapon_instance.remove_from_group("Weapon to be Destroyed")
	var orbital = ORBITING_SEED_ORBITAL.instantiate()
	orbital.player = player
	orbital.orbital = self
	orbital.weapon_instance = weapon_instance
	weapon_instance.add_child(orbital)
	list.append(weapon_instance)
	var hitbox = weapon_instance.get_node("Hitbox").get_collision_mask()
	var mask = hitbox & ~1 # ~ = NOT operator
	weapon_instance.get_node("Hitbox").set_collision_mask(mask)
	weapon_instance.source = player
	FIRE_RATE = weapon_instance.FIRE_RATE
	weapon_instance.seed_spawned.connect(set_spawned_item)
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = global_position

func set_spawned_item(_seed):
	_seed.remove_from_group("Weapon to be Destroyed")
	var orbital = ORBITING_SEED_ORBITAL.instantiate()
	orbital.player = player
	orbital.orbital = self
	orbital.weapon_instance = _seed
	_seed.seed_spawned.connect(set_spawned_item)
	_seed.add_child(orbital)
	list.append(_seed)
	FIRE_RATE = _seed.FIRE_RATE
	var hitbox = _seed.get_node("Hitbox").get_collision_mask()
	var mask = hitbox & ~1 # ~ = NOT operator
	_seed.get_node("Hitbox").set_collision_mask(mask)

func _on_fire_rate_timeout():
	set_item()
	if not seed: # prevent the weapon_fired signal from triggering if there are no seeds
		return
	player.weapon_fired.emit(weapon_instance)
	if player == Targets.get_player():
		player.seed_fired.emit(weapon_instance)
