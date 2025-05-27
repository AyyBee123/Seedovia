extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const AVOCADO_SEED = preload("res://Scenes/Seeds/Effects/Avocado Seed.tscn")
const AVOCADO_LEFT = preload("res://Scenes/Seeds/Effects/Avocado Left.tscn")
const AVOCADO_RIGHT = preload("res://Scenes/Seeds/Effects/Avocado Right.tscn")

var range_reached: bool

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.45
	splash.source = self
	if shader:
		splash.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		splash.get_node("AnimatedSprite2D").material.shader = shader
	splash.modulate = Color("a8c445")
	SfxDeconflicter.play(Game.audio_manager.crunch)
	SfxDeconflicter.play(Game.audio_manager.hit_2)
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.crunch)
	explode()
	destroy()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		if not range_reached:
			range_reached_done()
			range_reached = true

func range_reached_done():
	# spawn the seed
	if get_next_weapon():
		weapon_direction = direction
		shoot_next_weapon()
	else:
		var avocado_seed = AVOCADO_SEED.instantiate()
		avocado_seed.BASE_SPEED = BASE_SPEED
		avocado_seed.BASE_RANGE = BASE_RANGE * 1.5
		avocado_seed.BASE_DAMAGE = BASE_DAMAGE * 1.5
		avocado_seed.BASE_FIRE_RATE = BASE_FIRE_RATE * 1.5
		shoot_current_seed(avocado_seed, direction)
	
	# spawn the left side
	var avocado_left = AVOCADO_LEFT.instantiate()
	avocado_left.BASE_SPEED = BASE_SPEED
	avocado_left.BASE_RANGE = BASE_RANGE
	avocado_left.BASE_DAMAGE = BASE_DAMAGE * 0.5
	avocado_left.BASE_FIRE_RATE = BASE_FIRE_RATE
	avocado_left.parent_direction = direction
	avocado_left.angle_sign = -1
	shoot_current_seed(avocado_left, direction.rotated(-PI/2), global_position + 3 * direction.rotated(-PI/2).normalized())
	
	# spawn the right side
	var avocado_right = AVOCADO_RIGHT.instantiate()
	avocado_right.BASE_SPEED = BASE_SPEED
	avocado_right.BASE_RANGE = BASE_RANGE
	avocado_right.BASE_DAMAGE = BASE_DAMAGE * 0.5
	avocado_right.BASE_FIRE_RATE = BASE_FIRE_RATE
	avocado_right.parent_direction = direction
	avocado_right.angle_sign = 1
	shoot_current_seed(avocado_right, direction.rotated(PI/2), global_position + 3 * direction.rotated(PI/2).normalized())
	
	explode()
	destroy()

func shoot_current_seed(instantiated_weapon, _desired_direction = desired_direction, pos = global_position):
	instantiated_weapon.scale = scale
	if get_node_or_null("Passives"):
		instantiated_weapon.add_child(get_node("Passives").duplicate())
	if get_node_or_null("Visual Effects"):
		instantiated_weapon.add_child(get_node("Visual Effects").duplicate())
	super.shoot_current_seed(instantiated_weapon, _desired_direction, pos)
