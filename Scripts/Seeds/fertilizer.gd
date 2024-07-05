extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var lifetime = $Lifetime
@onready var tick_rate = $"Tick Rate"

var time_to_live = 5
var is_in_area := false
var enemy = null

func _ready():
	super._ready()
	visible = false # to remove jittering when the seed spawns

func _physics_process(delta):
	super._physics_process(delta)
	if is_in_area:
		if tick_rate.is_stopped():
			enemy._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
			tick_rate.start()

func initialize_position():
	if not position_initialized:
		# spawn the poop behind the player or previous seed
		global_position += Vector2(-desired_direction.x, desired_direction.y).normalized() * 10
		visible = true
		starting_position = global_position
		direction = -desired_direction.normalized()
		position_initialized = true

func travelled_distance():
	pass

func _collide(body):
	pass

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed")\
	* speed_multiplier * deceleration.time_left
	position += current_velocity * delta

func _on_deceleration_timeout():
	lifetime.start(time_to_live)

func _on_lifetime_timeout():
	var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2\
		else PlayerSeeds.seeds[slot_index + 1]
	attempted_fire.emit()
	if weapon != null:
		shoot_next_weapon(weapon)
	queue_free.call_deferred()

func shoot_next_weapon(weapon):
	var weapon_instance = weapon.instantiate()
	weapon_direction = Vector2.RIGHT
	weapon_direction = weapon_direction.rotated(randf_range(0, 2 * PI))
	get_weapon_properties(weapon_instance, weapon_direction)

func _on_hurtbox_area_entered(area):
	if area.is_in_group("Enemies"):
		enemy = area.get_parent()
		is_in_area = true

func _on_hurtbox_area_exited(area):
	if area.is_in_group("Enemies"):
		is_in_area = false
