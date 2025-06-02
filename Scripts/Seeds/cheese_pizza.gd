extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const KNOCKBACK = preload("res://Scenes/Seeds/Effects/Knockback.tscn")

var rotate_dir
var distance_to_shoot: float
var distance = 50

func _ready():
	super._ready()
	randomize()
	rotate_dir = -1 if randf() < 0.5 else 1

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	if body.is_in_group("Enemies"):
		has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
		var knockback_direction = global_position.direction_to(body.get_parent().global_position)
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
		SfxDeconflicter.play(Game.audio_manager.smack)
		SfxDeconflicter.play(Game.audio_manager.hit)
		
		# add a node to the enemy that knocks them back when hit by the block of cheese
		var knockback_scene = KNOCKBACK.instantiate()
		knockback_scene.knockback_direction = knockback_direction
		knockback_scene.knockback_speed = SPEED
		knockback_scene.damage = DAMAGE
		if not body.get_parent().find_child(knockback_scene.name):
			# add node to the enemy that gives velocity/position change and makes them take damage if they hit a wall
			body.get_parent().add_child(knockback_scene)
	elif body.is_in_group("Players"):
		var knockback_direction = global_position.direction_to(body.get_parent().global_position)
		body._player_stats.take_damage(1)
		SfxDeconflicter.play(Game.audio_manager.smack)
		SfxDeconflicter.play(Game.audio_manager.hit)
		# add a node to the enemy that knocks them back when hit by the block of cheese
		var knockback_scene = KNOCKBACK.instantiate()
		knockback_scene.knockback_direction = knockback_direction
		knockback_scene.knockback_speed = SPEED * 0.75
		knockback_scene.damage = 0
		if not body.find_child(knockback_scene.name):
			# add node to the enemy that gives velocity/position change and makes them take damage if they hit a wall
			body.add_child(knockback_scene)
	
	explode()
	destroy()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta
	rotation += PI/2 * delta * rotate_dir

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func initialize_location(weapon):
	super.initialize_location(weapon)
	distance = weapon.FIRE_RATE
	
func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	distance_to_shoot += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		destroy()
	if get_next_weapon():
		if distance_to_shoot >= 325.0 / distance:
			shoot_next_weapon()
			distance_to_shoot = 0

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.24 * SIZE
	splash.source = self
	splash.modulate = Color("cb8022")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
