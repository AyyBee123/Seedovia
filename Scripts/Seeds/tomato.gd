extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const TOMATO_POOL = preload("res://Scenes/Seeds/Effects/Tomato Pool.tscn")

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
	for i in 2:
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
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		destroy()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.24 * SIZE
	splash.source = self
	splash.modulate = Color("9e302a")
	call_deferred("create_child", splash)
	call_deferred("create_pool")

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func create_pool():
	shoot_current_seed(TOMATO_POOL.instantiate())
	var pool = TOMATO_POOL.instantiate()

func shoot_current_seed(instantiated_weapon, _desired_direction = desired_direction, pos = global_position):
	instantiated_weapon.add_child(get_node("Passives").duplicate())
	super.shoot_current_seed(instantiated_weapon, _desired_direction, pos)
