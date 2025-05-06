extends CharacterBody2D

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall

@onready var marker_2d = %Marker2D
@onready var hand = %Hand
@onready var fire_rate = $"Fire Rate"
@onready var weapon_direction_marker = $"Marker2D/Weapon Direction"

var targeted_enemy
var direction: Vector2
var second_seed
var player
var weapon_direction: Vector2

var DAMAGE: float = 8
var BLAST_RADIUS: float = 0.5
var FIRE_RATE: float = 4
var RANGE: float = 100
var SIZE: float = 0.5
var SPEED: float = 600
var ACCELERATION: float = 0.075
var FRICTION: float = 0.05

func _ready():
	player = Targets.get_player()
	check_seed_slot()
	SignalBus.inventory_changed.connect(check_seed_slot)
	SPEED = player.SPEED * 1.2

func _physics_process(delta):
	if targeted_enemy == null:
		targeted_enemy = get_nearest_enemy()
	
	if targeted_enemy:
		direction = global_position.direction_to(targeted_enemy.global_position).normalized()
		weapon_direction = direction
		marker_2d.look_at(targeted_enemy.global_position)
		approach(delta)
	else:
		marker_2d.rotation = direction.angle()
		stop()
	
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true

func approach(delta):
	if global_position.distance_to(get_nearest_enemy().global_position) > RANGE * 0.75:
		velocity = velocity.lerp(direction * SPEED, ACCELERATION)
		$AnimatedSprite2D.play("Move")
	elif global_position.distance_to(get_nearest_enemy().global_position) < RANGE * 0.75:
		velocity = velocity.lerp(-direction * SPEED, ACCELERATION)
		$AnimatedSprite2D.play("Move")
	else:
		velocity = velocity.lerp(Vector2.ZERO, FRICTION)
		$AnimatedSprite2D.play("Idle")
	
	if global_position.distance_to(get_nearest_enemy().global_position) <= RANGE:
		if fire_rate.is_stopped() and second_seed:
			shoot(second_seed)
			fire_rate.start(1.0 / FIRE_RATE)
	
	move_and_slide()

func stop():
	direction = global_position.direction_to(player.global_position)
	weapon_direction = direction
	
	if global_position.distance_to(player.global_position) > 100:
		velocity = velocity.lerp(direction * SPEED, ACCELERATION)
		$AnimatedSprite2D.play("Move")
	else:
		velocity = velocity.lerp(Vector2.ZERO, FRICTION * 5)
		$AnimatedSprite2D.play("Idle")
	
	move_and_slide()

func shoot(seed):
	var weapon_instance = seed.instantiate()
	weapon_instance.initial_weapon = true
	weapon_instance.previous_weapon = self
	weapon_instance.source = self
	weapon_instance.seed_slot_number = 1
	if PlayerInventory.seeds.has(0):
		weapon_instance.slot_index = 1
	else:
		weapon_instance.slot_index = 0
	weapon_instance.desired_direction = hand.global_position.direction_to(targeted_enemy.global_position)
	weapon_instance.transferred_damage_multiplier *= 0.5
	weapon_instance.transferred_size_multiplier *= 0.5
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = hand.global_position
	weapon_fired.emit(weapon_instance)

func check_seed_slot():
	second_seed = null if PlayerInventory.seeds.get(1) == null else PlayerInventory.seeds.get(1).scene
	
	if second_seed:
		var seed = second_seed.instantiate()
		RANGE = seed.RANGE
		FIRE_RATE = seed.FIRE_RATE

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
