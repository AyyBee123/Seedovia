extends "res://Scripts/Seeds/seed_template.gd"

@onready var move_time = $"Move Time"
@onready var move_delay = $"Move Delay"
@onready var fire_rate = $"Fire Rate"
@onready var animated_sprite_2d = $AnimatedSprite2D

var cow_fire_rate_multiplier = 0.25
var enemy

var enemies_in_area: Array
var tick_timers: Array
var tick_rate := 0.5
var alt_direction: float

func _ready():
	randomize()
	super._ready()
	fire_rate.start(0.5)

func _physics_process(delta):
	super._physics_process(delta)
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				if enemies_in_area[i] == player:
					enemies_in_area[i]._player_stats.take_damage(1)
					tick_timers[i].start(tick_rate)
					return
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start(tick_rate)
	
	if fire_rate.is_stopped():
		for i in 4:
			weapon_direction = Vector2.RIGHT.rotated(PI/2 * i + alt_direction)
			shoot_next_weapon()
		
		# alternate between cardianl and diagonal shots
		if alt_direction == 0:
			alt_direction = PI/4
		else:
			alt_direction = 0

func initialize_location(weapon):
	super.initialize_location(weapon)
	fire_rate.start(1.0 / (cow_fire_rate_multiplier * weapon.FIRE_RATE))

func set_direction():
	if not enemy:
		enemy = get_nearest_enemy()
	if enemy:
		direction = global_position.direction_to(enemy.global_position)
	else:
		var rand_y_dir = [-1, 0, 1]
		direction.x = 1 if randf() > 0.5 else -1
		direction.y = rand_y_dir.pick_random()
		direction = direction.normalized()

func move():
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.offset.x = -12
	else:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.offset.x = 12
	
	position += direction * SPEED * get_physics_process_delta_time()

func stop():
	pass

func update_position(delta):
	pass

func _collide(body):
	if body.is_in_group("Enemies"):
		if is_instance_valid(body):
			enemies_in_area.append(body.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate / FIRE_RATE
			timer.one_shot = true
			tick_timers.append(timer)

func get_nearest_enemy():
	var enemies = Targets.get_enemy_hitboxes()
	var nearest_enemy = null
	var nearest_distance = null
	for i in enemies.size():
		if nearest_enemy == null:
			if is_instance_valid(enemies[i]): # prevents game from crashing if enemy dies to quickly
				nearest_enemy = enemies[i]
				nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
		else:
			if is_instance_valid(enemies[i]):
				if nearest_distance > enemies[i].global_position.distance_squared_to(global_position):
					nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
					nearest_enemy = enemies[i]
	return nearest_enemy
