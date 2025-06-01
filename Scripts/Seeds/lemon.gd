extends "res://Scripts/Seeds/seed_template.gd"

@onready var point_1 = $Point1
@onready var point_2 = $Point2

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const LEMON_POOL = preload("res://Scenes/Seeds/Effects/Lemon Pool.tscn")

var pos
var point
var rotate_dir

func _ready():
	super._ready()
	randomize()
	rotate_dir = -1 if randf() < 0.5 else 1

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	shoot_next_weapon()
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.maple_splat)
	
	explode()
	destroy()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta
	rotation += PI/4 * delta * rotate_dir

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	point = [point_1, point_2].pick_random()
	weapon_direction = global_position.direction_to(point.global_position)
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func initialize_location(weapon_instance):
	if not get_tree():
		return
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = point.global_position
	weapon_fired.emit(weapon_instance)
	
func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		destroy()

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

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.24 * SIZE
	splash.source = self
	splash.modulate = Color("ffff3f")
	call_deferred("create_child", splash)
	call_deferred("create_pool")

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func create_pool():
	shoot_current_seed(LEMON_POOL.instantiate())
	var pool = LEMON_POOL.instantiate()

func shoot_current_seed(instantiated_weapon, _desired_direction = desired_direction, pos = global_position):
	instantiated_weapon.add_child(get_node("Passives").duplicate())
	super.shoot_current_seed(instantiated_weapon, _desired_direction, pos)
