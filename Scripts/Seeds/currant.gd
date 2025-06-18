extends "res://Scripts/Seeds/seed_template.gd"

@onready var homing_time = $"Homing Time"
@onready var bounce_homing_delay = $"Bounce Homing Delay"
@onready var pointer = %Pointer
@onready var marker_2d = %Marker2D

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

const NEXT_SEED_CHANCE = 0.2
var ROTATION_SPEED = 25
const NUMBER_OF_BOUNCES = 2

var is_homing: bool = true
var rotation_speed: float
var targeted_enemy
var bounces: int

func _ready():
	randomize()
	super._ready()
	pointer.rotation = desired_direction.angle()
	if target_group == "Players":
		homing_time.start()

func update_position(delta):
	if targeted_enemy == null:
		targeted_enemy = get_nearest_enemy(null)
	
	if targeted_enemy and is_homing:
		direction = global_position.direction_to(targeted_enemy.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed * delta)
	
	current_velocity = global_position.direction_to(marker_2d.global_position) * SPEED
	position += current_velocity * delta
	rotation_speed += ROTATION_SPEED * delta

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
		has_collided.emit(body)
		if randf() < NEXT_SEED_CHANCE:
			weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
			shoot_next_weapon()
		SfxDeconflicter.play(Game.audio_manager.hit)
		SfxDeconflicter.play(Game.audio_manager.spore_pop)
		explode()
		bounce(body)

func get_nearest_enemy(enemy):
	var enemies = get_tree().get_nodes_in_group("Enemies")
	if target_group == "Players":
		enemies = [Targets.get_player()]
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

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.175 * SIZE
	splash.source = self
	splash.modulate = Color("ff0031")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func _on_homing_time_timeout():
	is_homing = false

func bounce(body):
	if bounces < NUMBER_OF_BOUNCES:
		total_distance = 0
		bounces += 1
		direction = body.get_parent().global_position.direction_to(global_position)
		pointer.rotation = direction.angle()
		ignore_first_collision = true
		is_homing = false
		bounce_homing_delay.start()
	else:
		destroy()

func _on_bounce_homing_delay_timeout():
	is_homing = true
