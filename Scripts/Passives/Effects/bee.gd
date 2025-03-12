extends AnimatedSprite2D

var position_initialized = false
var direction: Vector2
var damage_multiplier: float
var spread: float
var speed: float
var weapon_direction: Vector2
var source_pos # so the bee doesn't just randomly change enemy targets mid-flight
var previous_weapon
var nearest_enemy

var DAMAGE: float
var BLAST_RADIUS: float = 0.1
var FIRE_RATE: float
var RANGE: float
var SIZE: float = 0.1
var SPEED: float

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall

@onready var player = Targets.get_player()
@onready var direction_shift_time = $"Direction Shift Time"
@onready var resource_preloader = $ResourcePreloader

func _ready():
	previous_weapon.weapon_fired.emit(self)
	global_position = source_pos
	source_pos = previous_weapon.global_position
	look_at(global_position + weapon_direction)

func _physics_process(delta):
	if get_nearest_enemy(null) != null:
		var rotation_angle = global_position.direction_to(get_nearest_enemy(null).global_position).angle()
		var new_rot = lerp_angle(rotation, rotation_angle, 7.5 * delta)
		rotation = new_rot
	update_position(delta)

func update_position(delta):
	var current_velocity: Vector2 = transform.x * speed # move in direction it's rotated
	position += current_velocity * delta

func _on_hitbox_area_entered(area):
	has_collided.emit(area)
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(DAMAGE * damage_multiplier)
	explode()
	queue_free.call_deferred()

func explode():
	var explosion = resource_preloader.get_resource("Splash").instantiate()
	explosion.size = 0.1
	explosion.source = self
	explosion.modulate = Color.YELLOW
	call_deferred("create_child", explosion)
	queue_free.call_deferred()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func _on_lifetime_timeout():
	explode()
	queue_free.call_deferred()

func get_nearest_enemy(object):
	var enemies = Targets.get_enemy_hitboxes()
	if object != null and object.is_in_group("Enemies"):
		# removes the hit enemy from the array so that the projectile does not target it when "bouncing"
		for i in range(enemies.size()):
			if enemies[i] == object:
				enemies.remove_at(i)
				break # break out of the loop because only one enemy is hit anyway, so it's reduntent to continue
	var nearest_enemy = null
	var nearest_distance = null
	for i in enemies.size():
		if nearest_enemy == null:
			if is_instance_valid(enemies[i]): # prevents game from crashing if enemy dies to quickly
				nearest_enemy = enemies[i]
				nearest_distance = enemies[i].global_position.distance_squared_to(source_pos)
		else:
			if is_instance_valid(enemies[i]):
				if nearest_distance > enemies[i].global_position.distance_squared_to(source_pos):
					nearest_distance = enemies[i].global_position.distance_squared_to(source_pos)
					nearest_enemy = enemies[i]
	return nearest_enemy
