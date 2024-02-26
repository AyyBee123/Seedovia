extends CharacterBody2D

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats
@onready var seed_slots := $"../Player/Inventory/NinePatchRect/Seed Slots".get_children()

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet

# this value is set because the weapon's position is not updated until after the ready function.
# That's why it's called in the physics process function instead of the ready function
var position_initialized := false

var initial_weapon := true
var ignore_first_collision := false # this is to let the projectiles spawn without instantly colliding with an object
var short_distance_travelled: float # this lets the projectile move a little before enabling collisions again

var slot_index: int

func _physics_process(delta):
	initialize_position()
	collision_detect(delta)
	travelled_distance()
	distance_after_collision()

func _on_bullet_hitbox_body_entered(body):
	_collide(body)
	
func _on_bullet_hitbox_area_entered(area):
	_collide(area)
	
func _collide(body):
	if not ignore_first_collision:
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage"))
		for i in range(seed_slots.size()):
			var weapon = PlayerSeeds.load_weapon(slot_index + 1)
			if weapon != null:
				shoot_next_weapon(weapon, body)
			break
		queue_free()
	else:
		ignore_first_collision = false
	
func shoot_next_weapon(weapon, enemy):
	var enemies = get_tree().get_nodes_in_group("Enemies")
	# removes the hit enemy from the array so that the projectile does not target it when "buncing"
	for i in range(enemies.size()): 
		if enemies[i] == enemy:
			enemies.remove_at(i)
			break # break out of the loop because only one enemy is hit anyway, so it's reduntent to continue
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
	
	var weapon_instance = weapon.instantiate()
	weapon_instance.initial_weapon = false
	weapon_instance.ignore_first_collision = true
	weapon_instance.slot_index = slot_index + 1
	call_deferred("initialize_location", weapon_instance, nearest_enemy)
	
func initialize_location(weapon_instance, nearest_enemy):
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = global_position
	weapon_instance.velocity = -velocity if nearest_enemy == null else (nearest_enemy.global_position - global_position).normalized()
	weapon_instance.rotation = weapon_instance.velocity.angle()
	
func initialize_position():
	if not position_initialized:
		if initial_weapon:
			slot_index = 0
		starting_position = global_position
		position_initialized = true

func collision_detect(delta):
	var collision_detect = move_and_collide(velocity * delta * _player_stats.get_stat("Weapon_Speed"))
	
func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= _player_stats.get_stat("Weapon_Range"):
		queue_free()
		
func distance_after_collision():
	short_distance_travelled = starting_position.distance_to(self.global_position)
	if short_distance_travelled >= 1:
		ignore_first_collision = false
