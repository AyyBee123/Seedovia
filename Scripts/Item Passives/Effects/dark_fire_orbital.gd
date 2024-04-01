extends Node2D

@onready var tick_rate = $"Tick Rate"

var d: float = 0
var weapon = null
var radius: float = 20
var speed: float = 5
var weapon_position
var damage
var initial_position
var current_velocity
var is_in_area := false
var enemy = null

func _ready():
	pass
	#radius = global_position.distance_to(weapon.global_position)

func _process(delta):
	if weapon != null:
		weapon_position = weapon.global_position
		current_velocity = weapon.current_velocity * delta
	else:
		shrink(delta)
	d += delta
	global_position = Vector2(
		sin(d * speed) * radius,
		cos(d * speed) * radius
	) * initial_position + weapon_position
	if is_in_area:
		if tick_rate.is_stopped():
			enemy._enemy_stats.take_damage(damage)
			tick_rate.start()

func shrink(delta):
	weapon_position += current_velocity * $AnimatedSprite2D.scale.x
	$AnimatedSprite2D.scale -= Vector2(delta, delta)
	if $AnimatedSprite2D.scale <= Vector2.ZERO:
		queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemies"):
		enemy = area.get_parent()
		is_in_area = true

func _on_area_2d_area_exited(area):
	if area.is_in_group("Enemies"):
		is_in_area = false
