extends "res://Scripts/Seeds/seed_template.gd"

@onready var down = $Down
@onready var up = $Up
@onready var left = $Left
@onready var right = $Right
@onready var resource_preloader = $ResourcePreloader
@onready var metal_1_SFX = $Metal1
@onready var metal_2_SFX = $Metal2

var area_normal # gets the normal of the collsion area/wall
var animation_frame = 0

func _ready():
	area_normal = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _physics_process(delta):
	super._physics_process(delta)
	rotation = 0 # locks the rotation of the parent node (to prevent shapecasts from rotating)

func update_position(delta):
	current_velocity = direction * player._player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta
	$AnimatedSprite2D.look_at(global_position + current_velocity)

func travelled_distance():
	distance_travelled = starting_position.distance_squared_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
		animation_frame = (animation_frame + 1) % $AnimatedSprite2D.sprite_frames.get_frame_count("default")
		$AnimatedSprite2D.set_frame(animation_frame)
	if total_distance >= player._player_stats.get_stat("Weapon_Range") * range_multiplier:
		queue_free.call_deferred()

func _on_hitbox_area_entered(area):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	# shapecasts allow the projectile to bounce after detecting an enemy
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
	collide(area)

func shoot_next_weapon():
	# for passives that require the weapon to not fire a seed (e.g the last seed slot fires itself again)
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), area_normal, true)

func collide(area):
	var sounds = [metal_1_SFX, metal_2_SFX]
	SfxDeconflicter.play(sounds.pick_random())
	if ignore_first_collision:
		ignore_first_collision = false
		return
	if area != null:
		has_collided.emit(area)
	explode()
	shoot_next_weapon()

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	weapon.global_position = global_position

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = _player_stats.get_stat("Weapon_Damage") * damage_multiplier * 0.25
	explosion.size = _player_stats.get_stat("Weapon_Blast_Radius") * blast_radius_multiplier
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.INDIAN_RED
	create_explosion.call_deferred(explosion)

func create_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
