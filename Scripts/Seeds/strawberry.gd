extends "res://Scripts/Seeds/seed_template.gd"

@onready var fire_rate = $"Fire Rate"
@onready var resource_preloader = $ResourcePreloader
@onready var homing_time = $"Homing Time"

var targeted_enemy = null
var strawberry_fire_rate_multiplier: float = 0.6
var explosion_damage_multiplier: float = 2.5
var exploded := false
var is_homing: bool = true

func _ready():
	super._ready()
	look_at(global_position + desired_direction)
	if target_group == "Players":
		homing_time.start()
	if get_next_weapon():
		fire_rate.start(get_next_weapon().instantiate().FIRE_RATE)

func _physics_process(delta):
	super._physics_process(delta)
	if targeted_enemy == null:
		targeted_enemy = get_nearest_enemy(null)
	else:
		var rotation_angle = global_position.direction_to(targeted_enemy.global_position).angle()
		var new_rot = lerp_angle(rotation, rotation_angle, 5 * delta)
		if is_homing:
			rotation = new_rot
	if fire_rate.is_stopped():
		shoot_next_weapon()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = DAMAGE
	explosion.size = BLAST_RADIUS
	explosion.source = self
	explosion.collisions = collisions
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	explosion.modulate = Color("bc1414")
	call_deferred("create_child", explosion)

func create_child(child):
	SfxDeconflicter.play(Game.audio_manager.strawberry_mild_explosion)
	visible = false
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
	queue_free.call_deferred()

func update_position(delta):
	var current_velocity: Vector2
	if not exploded:
		# move in direction it's rotated
		current_velocity = transform.x * SPEED
	else:
		current_velocity = Vector2.ZERO
	position += current_velocity * delta

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		if not exploded:
			exploded = true
			explode()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if not exploded:
		exploded = true
		explode()

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	fire_rate.wait_time = 1.0 / (strawberry_fire_rate_multiplier \
			* get_next_weapon().instantiate().FIRE_RATE)
	set_weapon_properties(get_next_weapon().instantiate(), transform.x)
	fire_rate.start()

func get_nearest_enemy(object):
	var enemies = Targets.get_enemy_hitboxes()
	if target_group == "Players":
		enemies = [Targets.get_player()]
	if object != null and object.is_in_group(target_group):
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
				nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
		else:
			if is_instance_valid(enemies[i]):
				if nearest_distance > enemies[i].global_position.distance_squared_to(global_position):
					nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
					nearest_enemy = enemies[i]
	return nearest_enemy

func _on_homing_time_timeout():
	is_homing = false
