extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var depression_area_sprite = $"Depression Area Sprite"
@onready var fire_rate = $"Fire Rate"
@onready var lifetime = $Lifetime
@onready var aura_tick_rate = $"Aura Tick Rate"

var enemies_in_area: Array

var gloom_fire_rate_multiplier: float = 1

func _ready():
	super._ready()
	fire_rate.start(1.0/(player._player_stats.get_stat("Fire_Rate") * gloom_fire_rate_multiplier))

func _physics_process(delta):
	super._physics_process(delta)
	depression_area_sprite.rotation_degrees += 0.25

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier * deceleration.time_left
	position += current_velocity * delta
	if fire_rate.is_stopped():
		shoot_next_weapon()
	for enemy in enemies_in_area:
		if aura_tick_rate.is_stopped():
			if is_instance_valid(enemy):
				enemy._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
				has_collided.emit(enemy.get_node("Enemy Hitbox"))
				aura_tick_rate.start(0.1 / _player_stats.get_stat("Fire_Rate") * 10)

func travelled_distance():
	pass

func collide(body):
	pass

func shoot_next_weapon():
	attempted_fire.emit()
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
	if get_next_weapon() == null:
		return
	fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * gloom_fire_rate_multiplier \
			* get_next_weapon().instantiate().fire_rate_multiplier)
	get_weapon_properties(get_next_weapon().instantiate(), weapon_direction)
	fire_rate.start()

func _on_lifetime_timeout():
	queue_free.call_deferred()

func _on_depression_area_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.remove_at(enemies_in_area.find(area.get_parent()))

func _on_depression_area_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
		

func _on_deceleration_timeout():
	lifetime.start()
