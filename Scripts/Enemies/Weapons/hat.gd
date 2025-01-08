extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var damage_buffer = $"Damage Buffer"

var is_in_area: bool
var angle: float
var radius: float
var index

func _ready():
	super._ready()
	speed = 1.5

func _physics_process(delta):
	super._physics_process(delta)
	if is_in_area and damage_buffer.is_stopped():
		player._player_stats.take_damage(damage)
		damage_buffer.start()

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		is_in_area = true

func _on_bullet_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func update_position(delta):
	angle += delta
	global_position = Vector2(
		sin(angle * speed * -get_parent().direction.x + index * TAU / get_parent().NUMBER_OF_HATS) * radius,
		cos(angle * speed * -get_parent().direction.x + index * TAU / get_parent().NUMBER_OF_HATS) * radius
	) + get_parent().global_position

func travelled_distance():
	pass
