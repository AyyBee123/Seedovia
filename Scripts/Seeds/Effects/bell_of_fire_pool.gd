extends "res://Scripts/Seeds/seed_template.gd"

@onready var shoot_time = $"Shoot Time"
@onready var fire_rate = $"Fire Rate"

var enemies_in_area: Array
var tick_timers: Array
var tick_rate := 0.15
var tween

func _ready():
	randomize()
	modulate.a = 0
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.55)

func _physics_process(delta):
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start(tick_rate)
	rotation_degrees += 15 * delta
	
	if not shoot_time.is_stopped():
		if fire_rate.is_stopped():
			shoot_next_weapon()

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	super.shoot_next_weapon()
	fire_rate.start(1.0 / (3 * get_next_weapon().instantiate().FIRE_RATE))

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	weapon.global_position = global_position + weapon_direction * scale.x / 4 * 64 # 64 is the size of the texture

func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate
			timer.one_shot = true
			tick_timers.append(timer)

func _on_area_2d_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func _on_lifetime_timeout():
	if tween:
		tween.kill()
	queue_free()
