extends "res://Scripts/Seeds/seed_template.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D

const POT_FIRE_RATE_MULTIPLIER = 0.25
const POT_DAMAGE_MULTIPLIER = 0.8

var has_next_seed: bool
var target = null
var enemy
var _can_shoot: bool
var _can_bite: bool
var radius: float = 50
var angle := 0.0

func _ready():
	super._ready()
	transferred_damage_multiplier *= POT_DAMAGE_MULTIPLIER
	radius = $"Shoot Range/CollisionShape2D".shape.radius * scale.x

func _physics_process(delta):
	has_next_seed = get_next_weapon() != null
	super._physics_process(delta)
	if enemy == null:
		_can_bite = false
		_can_shoot = false
		enemy = get_nearest_enemy(null)
	if get_next_weapon() and enemy and global_position.distance_to(enemy.global_position) <= \
				get_next_weapon().instantiate().RANGE:
		target = enemy
		_can_shoot = true
	else:
		_can_shoot = false
	if $"Bite Range".get_overlapping_areas().size() > 0 and not get_next_weapon():
		target = $"Bite Range".get_overlapping_areas()[0]
		_can_bite = true
	else:
		_can_bite = false

func move():
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	angle = 0
	if enemy:
		direction = global_position.direction_to(enemy.global_position)
		current_velocity = direction * player._player_stats.get_stat("Weapon_Speed") * speed_multiplier
		position += current_velocity * get_physics_process_delta_time()
	else:
		current_velocity = Vector2.ZERO

func shoot():
	current_velocity = Vector2.ZERO
	if not is_instance_valid(target):
		_can_shoot = false
	animated_sprite_2d.flip_h = false
	angle += get_physics_process_delta_time()
	var speed = player._player_stats.get_stat("Weapon_Speed") * speed_multiplier / 100
	if is_instance_valid(target):
		if get_next_weapon():
			animated_sprite_2d.speed_scale = player._player_stats.get_stat("Fire_Rate") * POT_FIRE_RATE_MULTIPLIER \
					* get_next_weapon().instantiate().fire_rate_multiplier
			if not animated_sprite_2d.animation == "Shoot":
				animated_sprite_2d.play("Shoot")

func bite():
	current_velocity = Vector2.ZERO
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	animated_sprite_2d.speed_scale = player._player_stats.get_stat("Fire_Rate") / 10
	if not animated_sprite_2d.animation == "Bite":
		animated_sprite_2d.play("Bite")

func get_nearest_enemy(enemy):
	var enemies = get_tree().get_nodes_in_group("Enemies")
	if enemy != null:
		# removes the hit enemy from the array so that the projectile does not target it when "bouncing"
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
	return nearest_enemy

func _on_animated_sprite_2d_frame_changed():
	if not is_instance_valid(target) or target == null:
		return
	if animated_sprite_2d.animation == "Shoot":
		if animated_sprite_2d.frame == 4:
			if get_next_weapon():
				weapon_direction = global_position.direction_to(target.global_position).normalized()
				shoot_next_weapon()
	if animated_sprite_2d.animation == "Bite":
		if animated_sprite_2d.frame == 3:
			target.get_parent()._enemy_stats.take_damage(player._player_stats.get_stat("Weapon_Damage") \
					* damage_multiplier)
			SfxDeconflicter.play(Game.audio_manager.sentient_pot_bite)

func update_position(delta):
	pass

func _collide(body):
	pass

func travelled_distance():
	pass

func _on_lifetime_timeout():
	queue_free()
