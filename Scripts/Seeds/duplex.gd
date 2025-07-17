extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const DUPLEX = preload("res://Scenes/Seeds/Duplex.tscn")
const SPREAD = PI/4

var has_split: bool

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		split()
		explode()
		destroy()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.hit_4)
	weapon_direction = direction
	shoot_next_weapon()
	explode()
	destroy()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.25 * SIZE
	splash.source = self
	splash.modulate = Color("e04a74")
	splash.modulate.a = 188.0 / 255.0
	SfxDeconflicter.play(Game.audio_manager.bubble_pop_3)
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func split():
	if has_split:
		weapon_direction = direction
		shoot_next_weapon()
		return
	var directions = [-1, 1]
	for i in directions:
		shoot_current_seed(DUPLEX.instantiate(), direction.rotated(SPREAD * i))

func shoot_current_seed(instantiated_weapon, _desired_direction = desired_direction, pos = global_position):
	instantiated_weapon.has_split = true
	super.shoot_current_seed(instantiated_weapon, _desired_direction, pos)
