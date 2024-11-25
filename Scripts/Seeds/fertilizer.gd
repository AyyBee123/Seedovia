extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var lifetime = $Lifetime
@onready var tick_rate = $"Tick Rate"
@onready var stink_rate = $"Stink Rate"
@onready var resource_preloader = $ResourcePreloader

var time_to_live = 5
var is_in_area := false
var enemy = null
var hit_wall := false

func _ready():
	super._ready()
	visible = false # to remove jittering when the seed spawns
	# spawn the poop behind the player or previous seed
	global_position += Vector2(-desired_direction.x, desired_direction.y).normalized() * 10
	visible = true
	starting_position = global_position
	direction = -desired_direction.normalized()

func _physics_process(delta):
	super._physics_process(delta)
	if is_in_area:
		if tick_rate.is_stopped():
			enemy._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
			has_collided.emit(enemy.get_node("Enemy Hitbox"))
			tick_rate.start()

func travelled_distance():
	pass

func _collide(body):
	pass

func update_position(delta):
	if not hit_wall:
		current_velocity = direction * _player_stats.get_stat("Weapon_Speed") \
				* speed_multiplier * deceleration.time_left
		position += current_velocity * delta

func _on_deceleration_timeout():
	lifetime.start(time_to_live)
	stink_rate.start()

func _on_lifetime_timeout():
	var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 \
			else PlayerSeeds.seeds[slot_index + 1]
	shoot_next_weapon()
	queue_free.call_deferred()

func shoot_next_weapon():
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
	super.shoot_next_weapon()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("Enemies"):
		enemy = area.get_parent()
		is_in_area = true

func _on_hurtbox_area_exited(area):
	if area.is_in_group("Enemies"):
		is_in_area = false

func _on_hitbox_body_entered(body):
	hit_wall = true

func _on_stink_rate_timeout():
	var stink = resource_preloader.get_resource("Stink").instantiate()
	var stink_direction = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
	stink.direction = stink_direction
	get_tree().current_scene.add_child(stink)
	stink.global_position = global_position
	stink_rate.start()
