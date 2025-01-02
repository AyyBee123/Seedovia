extends "res://Scripts/Enemies/Slime/slime.gd"

@onready var spin_time = $"Spin Time"
@onready var spin_fire_rate = $"Spin Fire Rate"
@onready var pop_rate = $"Pop Rate"
@onready var pop_SFX = $Pop

var launch_direction # for Jumbo boss
var launch_speed # for Jumbo boss
var starting_state = null

const ORBITING_BULLET = preload("res://Scenes/Enemies/Weapons/Orbiting Bullet.tscn")

func _ready():
	super._ready()
	spin_fire_rate.wait_time = 1.0 / _enemy_stats.fire_rate
	animated_sprite_2d.position = Vector2(-1, -2)

func spin():
	if spin_time.is_stopped():
		spin_time.start()
	if spin_fire_rate.is_stopped():
		spin_fire_rate.start()
		var bullet = ORBITING_BULLET.instantiate()
		bullet.speed = _enemy_stats.weapon_speed
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = animated_sprite_2d.global_position
	if pop_rate.is_stopped():
		pop_rate.start()
		pop_SFX.play()

func spawn():
	var current_velocity: Vector2 = launch_direction * launch_speed
	position += current_velocity * get_physics_process_delta_time()

func _on_spin_time_timeout():
	animated_sprite_2d.play("Spin End")

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Spin Beginning":
		animated_sprite_2d.play("Spin")
	if animated_sprite_2d.animation == "Spin End":
		spin_time.stop()
		_state_machine.set_state(_state_machine.states.idle)

func set_state_idle():
	_state_machine.set_state(_state_machine.states.idle)
