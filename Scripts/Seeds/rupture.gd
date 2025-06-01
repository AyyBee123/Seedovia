extends "res://Scripts/Seeds/seed_template.gd"

@onready var bottom = $Bottom
@onready var middle = $Middle
@onready var top = $Top
@onready var tick_rate = $"Tick Rate"
@onready var collision_shape_2d = $Hitbox/CollisionShape2D
@onready var fire_rate = $"Fire Rate"
@onready var hit_SFX = $Hit2
@onready var laser_SFX = $Laser2

const FIRE_RATE_MULTIPLIER = 1.5
const SPREAD = PI/4

var enemies_in_area: Array
var tick_timers: Array

func _ready():
	super._ready()
	# extends the beam length based on player range
	middle.scale.x = max(0, RANGE)
	top.position.x += middle.scale.x - 1 # places the top portion of the beam above the middle portion
	collision_shape_2d.shape.extents.x = 20 + middle.scale.x * 0.5
	collision_shape_2d.position.x = 16 + middle.scale.x * 0.5
	collision_shape_2d.disabled = true
	starting_position = global_position
	direction = desired_direction.normalized()
	rotation = desired_direction.angle()
	collision_shape_2d.disabled = false
	SfxDeconflicter.play(hit_SFX)
	SfxDeconflicter.play(laser_SFX)
	
	var tween = get_tree().create_tween()
	tween.tween_interval(0.175)
	var shrink_time = 0.175
	tween.tween_property($Bottom, "scale:y", 0, shrink_time)
	tween.parallel().tween_property($Middle, "scale:y", 0, shrink_time)
	tween.parallel().tween_property($Top, "scale:y", 0, shrink_time)
	tween.tween_callback(queue_free)

func _physics_process(delta):
	super._physics_process(delta)
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				if enemies_in_area[i] == player:
					enemies_in_area[i]._player_stats.take_damage(1)
					tick_timers[i].start(0.2 / FIRE_RATE)
					return
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start(0.2 / FIRE_RATE)
	
	if fire_rate.is_stopped():
		weapon_direction = direction.rotated(randf_range(-SPREAD, SPREAD))
		shoot_next_weapon()

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction)

func initialize_location(weapon):
	super.initialize_location(weapon)
	fire_rate.start(1.0 / (weapon.FIRE_RATE * FIRE_RATE_MULTIPLIER))

func update_position(delta):
	rotation = direction.angle()
	if is_instance_valid(previous_weapon):
		global_position = previous_weapon.global_position + direction * 4

func travelled_distance():
	pass

func _collide(body):
	if body.is_in_group("Enemies"):
		if is_instance_valid(body):
			enemies_in_area.append(body.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = 0.2 / FIRE_RATE
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hitbox_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		if is_instance_valid(body):
			enemies_in_area.append(body)
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = 0.2 / FIRE_RATE
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		if is_instance_valid(body):
			var index = enemies_in_area.find(body)
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)
