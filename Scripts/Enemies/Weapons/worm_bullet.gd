extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var spawn_delay = $"Spawn Delay"

const WORM_BULLET = preload("res://Scenes/Enemies/Weapons/Worm Bullet.tscn")

var NUMBER_OF_BULLETS: float = 6

var move_direction: Vector2
var angle: float
var angle_multi: float
var rotation_multi: float
var current_number_of_bullets: float
var current_size: float
var final_size: float
var t: float

func _ready():
	visible = false
	randomize()
	super._ready()
	
	await get_tree().physics_frame
	starting_position = global_position
	final_size = scale.x
	scale = Vector2.ZERO
	visible = true

func _physics_process(delta):
	super._physics_process(delta)
	
	t += delta * 5
	current_size = lerpf(current_size, final_size, t)
	
	scale = Vector2.ONE * current_size

func update_position(delta):
	angle += delta * angle_multi
	move_direction = direction.rotated(rotation_multi * sin(angle))
	var current_velocity: Vector2 = move_direction * speed
	position += current_velocity * delta

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_spawn_delay_timeout():
	if current_number_of_bullets >= NUMBER_OF_BULLETS - 1:
		return
	
	var bullet = WORM_BULLET.instantiate()
	bullet.damage = damage
	bullet.range = range
	bullet.speed = speed
	bullet.direction = direction
	bullet.current_number_of_bullets = current_number_of_bullets + 1
	bullet.angle_multi = angle_multi
	bullet.rotation_multi = rotation_multi
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = starting_position
