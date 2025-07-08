extends Node2D

@onready var middle = $Middle
@onready var top = $Top
@onready var middle_collision = $"Enemy Hitbox/CollisionShape2D"

@export var _enemy_stats: enemy_stats

var length: float = 2
var hit_wall: bool
var source
var direction
var top_pos: Vector2
var player

func _ready():
	_enemy_stats = _enemy_stats.duplicate()
	_enemy_stats.initialize_stats(_enemy_stats)
	_enemy_stats.set_health(_enemy_stats.max_health)
	_enemy_stats.spawn_damage_number.connect(transfer_damage)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.change_color.connect(change_color)

func _physics_process(delta):
	if source._state_machine.state == source._state_machine.states.tongue_begin:
		launch(delta)
	elif source._state_machine.state == source._state_machine.states.launch:
		frog_launch(delta)
	visible = true

func frog_launch(delta):
	# make the tongue look like it's not moving and dragging the frog
	# i have no idea why subtracting 9 works here, but it does
	length = abs(top_pos.x - 9 * direction.x - source.global_position.x - source.get_node("Down").position.x * direction.x) \
			 / source.scale.x
	top.position.y = 6 - length
	middle.region_rect = Rect2(0, 0, middle.get_region_rect().size.x, length)
	middle_collision.position.y = -length / 2
	middle_collision.shape.size.y = length

func launch(delta):
	if hit_wall:
		return
	middle.region_rect = Rect2(0, 0, middle.get_region_rect().size.x, length)
	middle_collision.position.y = -length / 2
	middle_collision.shape.size.y = length
	top.position.y = 6 - length
	top_pos = top.global_position
	length += delta * _enemy_stats.speed

func transfer_damage(amount):
	if not is_instance_valid(source):
		return
	source._enemy_stats.take_damage(amount * 0.1)

func update_health(new_health):
	_enemy_stats.set_health(_enemy_stats.max_health)

func change_color():
	middle.material.set("shader_parameter/tint_factor", 0.8)
	top.material.set("shader_parameter/tint_factor", 0.8)
	await get_tree().create_timer(0.05, false).timeout
	middle.material.set("shader_parameter/tint_factor", 0.0)
	top.material.set("shader_parameter/tint_factor", 0.0)

func _on_area_2d_body_entered(body):
	Game.audio_manager.play(Game.audio_manager.bubble_pop_2)
	Game.audio_manager.play(Game.audio_manager.hit_2)
	hit_wall = true

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(_enemy_stats.damage)
