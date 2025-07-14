extends Sprite2D

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall

@onready var fire_rate = $"Fire Rate"

const FIRE_RATE_MULTIPLIER = 0.5

var angle: float
var radius: float
var player
var scene: PackedScene
var seed_slot: int
var seed_index: int = 3
var targeted_enemy
var weapon_direction: Vector2

var DAMAGE: float = 6
var BLAST_RADIUS: float = 0.5
var FIRE_RATE: float = 3
var RANGE: float = 400
var SIZE: float = 0.5
var SPEED: float = 600
var ACCELERATION: float = 0.075
var FRICTION: float = 0.05

func _ready():
	player = Targets.get_player()

func _physics_process(delta):
	# orbit around the player
	var speed = 2
	angle += delta * speed
	global_position = Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	) + player.global_position
	
	targeted_enemy = get_nearest_enemy()
	
	if fire_rate.is_stopped() and targeted_enemy and global_position.distance_to(targeted_enemy.global_position) <= RANGE:
		if scene == null:
			fire_rate.start(0.1)
			return
		var seed = scene.instantiate()
		weapon_direction = global_position.direction_to(targeted_enemy.global_position)
		seed.initial_weapon = true
		seed.desired_direction = weapon_direction
		seed.previous_weapon = self
		seed.source = self
		seed.slot_index = seed_index
		seed.seed_slot_number = seed_slot
		seed.transferred_size_multiplier *= 0.75
		seed.transferred_damage_multiplier *= 0.5
		seed.transferred_blast_radius_multiplier *= 0.75
		seed.BASE_RANGE *= 1.25
		seed.modulate = modulate
		get_tree().current_scene.add_child(seed)
		seed.global_position = global_position
		weapon_fired.emit(seed)
		fire_rate.start(1.0 / (FIRE_RATE_MULTIPLIER * seed.FIRE_RATE))

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var nearest_enemy = null
	var nearest_distance = null
	for i in enemies.size():
		if nearest_enemy == null:
			nearest_enemy = enemies[i]
			nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
		else:
			if nearest_distance > enemies[i].global_position.distance_squared_to(global_position):
				nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
				nearest_enemy = enemies[i]
	return nearest_enemy
