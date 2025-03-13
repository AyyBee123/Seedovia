extends "res://Scripts/Seeds/seed_template.gd"

@onready var down = $Down
@onready var up = $Up
@onready var left = $Left
@onready var right = $Right
@onready var resource_preloader = $ResourcePreloader
@onready var metal_1_SFX = $Metal1
@onready var metal_2_SFX = $Metal2
@onready var frame_change_timer = $"Frame Change Timer"

var area_normal # gets the normal of the collsion area/wall
var animation_frame = 0

func _ready():
	super._ready()
	area_normal = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	frame_change_timer.wait_time = 1.0 / (SPEED) * 50

func _physics_process(delta):
	super._physics_process(delta)
	rotation = 0 # locks the rotation of the parent node (to prevent shapecasts from rotating)

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta
	animation_frame = (animation_frame + 1) % $AnimatedSprite2D.sprite_frames.get_frame_count("default")
	if frame_change_timer.is_stopped():
		$AnimatedSprite2D.set_frame(animation_frame)
		$AnimatedSprite2D.look_at(global_position + current_velocity)
		frame_change_timer.start()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		queue_free.call_deferred()

func _on_hitbox_area_entered(area):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	# shapecasts allow the projectile to bounce after detecting an enemy
	collide(area)
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(DAMAGE)

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		body._player_stats.take_damage(1)
		collide(body)

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func collide(area):
	area_normal = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() # just in case
	if down.is_colliding():
		area_normal = Vector2(0, -1)
	elif up.is_colliding():
		area_normal = Vector2(0, 1)
	elif left.is_colliding():
		area_normal = Vector2(1, 0)
	elif right.is_colliding():
		area_normal = Vector2(-1, 0)
	direction = direction.bounce(area_normal).normalized()
	
	var sounds = [metal_1_SFX, metal_2_SFX]
	SfxDeconflicter.play(sounds.pick_random())
	if ignore_first_collision:
		ignore_first_collision = false
		return
	if area != null:
		has_collided.emit(area)
	explode()
	weapon_direction = area_normal
	shoot_next_weapon()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = DAMAGE * 0.25
	explosion.size = BLAST_RADIUS / 4
	explosion.collisions = collisions
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.INDIAN_RED
	create_explosion.call_deferred(explosion)

func create_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
