extends "res://Scripts/Seeds/seed_template.gd"

@onready var collision_shape_2d = $Hitbox/CollisionShape2D
@onready var fire_rate = $"Fire Rate"
@onready var end = $End
@onready var lifetime = $Lifetime

const SYRUP_FIRE_RATE_MULTIPLIER = 0.8

var rect_width = 0.0
var t = 0.0
var enemies_in_area := []
var tick_timers := []
var original_size := 0.0
var tick_rate := 0.25

func _ready():
	super._ready()
	randomize()
	set_lengths()
	original_size = scale.x
	SfxDeconflicter.play(Game.audio_manager.maple_splat)

func _physics_process(delta):
	super._physics_process(delta)
	t += delta * 10
	# damage all enemies that are in the prickle area
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start()
				has_collided.emit()
	if fire_rate.is_stopped() and rect_width == RANGE and not lifetime.is_stopped():
		weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		shoot_next_weapon()
		fire_rate.start()
	rect_width = min(RANGE * t, RANGE)
	set_lengths()
	if lifetime.is_stopped():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(scale.x, original_size / 4), 1)
		tween.parallel().tween_property(self, "modulate", Color(modulate.r, modulate.g, modulate.b, 0), 1)
		tween.finished.connect(queue_free)

func _on_hitbox_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hitbox_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func shoot_next_weapon():
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	var weapon_instance = get_next_weapon().instantiate()
	fire_rate.start(1.0 / (SYRUP_FIRE_RATE_MULTIPLIER * get_next_weapon().instantiate().FIRE_RATE))
	set_weapon_properties(weapon_instance, weapon_direction)

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	weapon.global_position = Vector2(randf_range(end.global_position.x, global_position.x), \
			randf_range(end.global_position.y, global_position.y))

func set_lengths():
	region_rect = Rect2(0, 0, rect_width, 40)
	collision_shape_2d.shape.size.x = get_region_rect().size.x
	collision_shape_2d.position.x = collision_shape_2d.shape.size.x / 2
	end.position.x = get_region_rect().size.x

func travelled_distance():
	pass

func update_position(delta):
	look_at(global_position + direction)

func set_ignore_first_collision():
	pass

func _collide(body):
	pass

func get_next_weapon_pos():
	return Vector2(randf_range(end.global_position.x, global_position.x), \
			randf_range(end.global_position.y, global_position.y))
