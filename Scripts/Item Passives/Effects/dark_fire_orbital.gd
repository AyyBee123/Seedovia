extends Node2D

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall
signal attempted_fire # signal for attempting to fire the next seed (even if the next seed is null)

var angle: float = 0
var weapon = null
var radius: float = 20
var speed: float = 5
var weapon_position: Vector2
var x_pos
var y_pos
var index: int
var current_velocity: Vector2
var is_in_area := false
var number_of_orbitals: int
var enemies_in_area: Array
var tick_timers: Array
var tick_rate := 0.05

var DAMAGE: float
var BLAST_RADIUS: float
var FIRE_RATE: float
var RANGE: float
var SIZE: float
var SPEED: float

func _ready():
	if weapon.texture == null:
		radius = 20
	else:
		radius = min(max(weapon.texture.get_width(), weapon.texture.get_height()), 20)
	weapon_position = weapon.global_position
	current_velocity = weapon.current_velocity

func _physics_process(delta):
	if is_instance_valid(weapon):
		weapon_position = weapon.global_position
		current_velocity = weapon.current_velocity * delta
		look_at(global_position + Vector2(sin(angle * speed + index * deg_to_rad(360.0/number_of_orbitals)), \
		cos(angle * speed + index * deg_to_rad(360.0/number_of_orbitals))).rotated(PI/2))
	else:
		shrink(delta)
	angle += delta
	# rotate the orbitals around the weapon
	global_position = Vector2(
		sin(angle * speed + index * deg_to_rad(360.0/number_of_orbitals)) * radius,
		cos(angle * speed + index * deg_to_rad(360.0/number_of_orbitals)) * radius
	) + weapon_position
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
			tick_timers[i].start(tick_rate)

func shrink(delta):
	weapon_position += current_velocity * $Sprite2D.scale.x
	look_at(global_position + Vector2(sin(angle * speed + index * deg_to_rad(360.0/number_of_orbitals)), \
		cos(angle * speed + index * deg_to_rad(360.0/number_of_orbitals))).rotated(PI/2))
	$Sprite2D.scale -= Vector2.ONE * delta * 2
	if $Sprite2D.scale <= Vector2.ZERO:
		queue_free()

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
