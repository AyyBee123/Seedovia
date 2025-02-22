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
var enemies_in_area: Array
var tick_timers: Array

func _ready():
	super._ready()
	visible = false # to remove jittering when the seed spawns
	# spawn the poop behind the player or previous seed
	global_position += Vector2(-desired_direction.x, desired_direction.y).normalized() * 10
	visible = true
	starting_position = global_position
	direction = -desired_direction.normalized()
	deceleration.start()

func _physics_process(delta):
	super._physics_process(delta)
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
				tick_timers[i].start(tick_rate.wait_time * FIRE_RATE)

func travelled_distance():
	pass

func _collide(body):
	pass

func update_position(delta):
	if not hit_wall:
		current_velocity = direction * SPEED * deceleration.time_left
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
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	super.shoot_next_weapon()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate.wait_time * FIRE_RATE
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hurtbox_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func _on_hitbox_body_entered(body):
	hit_wall = true

func _on_stink_rate_timeout():
	var stink = resource_preloader.get_resource("Stink").instantiate()
	var stink_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	stink.direction = stink_direction
	get_tree().current_scene.add_child(stink)
	stink.global_position = global_position
	stink_rate.start()
