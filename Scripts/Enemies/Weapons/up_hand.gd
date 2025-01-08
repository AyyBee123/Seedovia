extends "res://Scripts/Enemies/Weapons/bullet.gd"

@export var charge_direction: Vector2
@onready var damage_buffer = $"Damage Buffer"

const FUNNY_HAND = preload("res://Sprites/Bosses/Mad Hat/Funny Hand.png")

var hand
var mad_hat
var is_in_area

func _ready():
	super._ready()
	if randf() < 0.001:
		texture = FUNNY_HAND
	speed = 700
	direction = charge_direction

func _physics_process(delta):
	super._physics_process(delta)
	if is_in_area and damage_buffer.is_stopped():
		player._player_stats.take_damage(damage)
		damage_buffer.start()
	if not is_instance_valid(mad_hat):
		queue_free()

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		is_in_area = true

func _on_bullet_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func travelled_distance():
	pass

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	await get_tree().create_timer(1).timeout
	if hand != null:
		hand._state_machine.set_state(hand._state_machine.states.idle)
		hand.global_position = global_position
	queue_free()
