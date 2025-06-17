extends AnimatedSprite2D

var SPEED := 150.0

@export var _enemy_stats: enemy_stats

var direction: Vector2
var source
var player
var damage := 1
var rotation_direction
var _used_WTF: bool
var face_index = -1

func _ready():
	_enemy_stats = _enemy_stats.duplicate()
	_enemy_stats.initialize_stats(_enemy_stats)
	_enemy_stats.set_health(_enemy_stats.max_health)
	_enemy_stats.spawn_damage_number.connect(transfer_damage)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.change_color.connect(change_color)
	if _used_WTF:
		if randf() < 0.5:
			play("Normal")
		else:
			play("WTF")
	else:
		play("Normal")
	
	if randf() < 0.5:
		rotation_direction = 1
	else:
		rotation_direction = -1
	set_process(true)
	set_physics_process(true)
	show()

func _physics_process(delta):
	if not is_instance_valid(source):
		set_process(false)
		set_physics_process(false)
		$"Enemy Hitbox/CollisionShape2D".disabled = true
		hide()
	
	update_position(delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func update_position(delta):
	var current_velocity: Vector2 = direction * SPEED
	position += current_velocity * delta
	rotation += PI/4 * delta * rotation_direction

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(damage)

func transfer_damage(amount):
	if not is_instance_valid(source):
		return
	source._enemy_stats.take_damage(amount * 0.1)

func update_health(new_health):
	_enemy_stats.set_health(_enemy_stats.max_health)

func change_color():
	material.set("shader_parameter/tint_factor", 0.8)
	await get_tree().create_timer(0.05, false).timeout
	material.set("shader_parameter/tint_factor", 0.0)
