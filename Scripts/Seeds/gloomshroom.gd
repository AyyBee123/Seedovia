extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var depression_area_sprite = $"Depression Area Sprite"
@onready var fire_rate = $"Fire Rate"
@onready var lifetime = $Lifetime
@onready var aura_tick_rate = $"Aura Tick Rate"

var enemies_in_area: Array
var tick_timers: Array

var gloom_fire_rate_multiplier: float = 1

func _ready():
	super._ready()
	deceleration.start()
	fire_rate.start(1.0 / player._player_stats.get_stat("Fire_Rate") * fire_rate_multiplier)

func _physics_process(delta):
	super._physics_process(delta)
	depression_area_sprite.rotation_degrees += 0.25
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(player._player_stats.get_stat("Weapon_Damage") \
						* damage_multiplier)
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
				tick_timers[i].start(0.25 / player._player_stats.get_stat("Fire_Rate") * fire_rate_multiplier * 10)
	if fire_rate.is_stopped():
		shoot_next_weapon()

func update_position(delta):
	current_velocity = direction * player._player_stats.get_stat("Weapon_Speed") * speed_multiplier * deceleration.time_left
	position += current_velocity * delta

func travelled_distance():
	pass

func collide(body):
	pass

func shoot_next_weapon():
	attempted_fire.emit()
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	if get_next_weapon() == null:
		return
	fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * gloom_fire_rate_multiplier \
			* get_next_weapon().instantiate().fire_rate_multiplier)
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction)
	fire_rate.start()

func _on_lifetime_timeout():
	queue_free.call_deferred()

func _on_depression_area_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func _on_depression_area_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = 0.1 / _player_stats.get_stat("Fire_Rate") * 20
			timer.one_shot = true
			tick_timers.append(timer)

func _on_deceleration_timeout():
	lifetime.start()
