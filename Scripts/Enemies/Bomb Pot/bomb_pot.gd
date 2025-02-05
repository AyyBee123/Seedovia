extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var pointer = $Pointer
@onready var marker_2d = $Pointer/Marker2D
@onready var primed_timer = $"Primed Timer"
@onready var ready_timer = $"Ready Timer"
@onready var ding_SFX = $Ding

const ENEMY_EXPLOSION = preload("res://Scenes/Enemies/Weapons/Enemy Explosion.tscn")

var direction: Vector2
var INITIAL_SPEED
var rotation_speed: float

func _ready():
	super._ready()
	INITIAL_SPEED = _enemy_stats.speed
	randomize()
	rotation_speed = randf_range(2, 10)
	
	# look at the player's spawn point at the start to avoid turning when entering a new room
	pointer.rotation = global_position.direction_to(Vector2(0, 330)).angle()

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed * delta)
		velocity = global_position.direction_to(marker_2d.global_position) * _enemy_stats.speed
	
	if animated_sprite_2d.animation == "Ready":
		_enemy_stats.speed -= 5
	
	if animated_sprite_2d.animation == "Primed":
		_enemy_stats.speed = min(INITIAL_SPEED * 1.75, _enemy_stats.speed + 5)
		rotation_speed += 1.25 * delta
	
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Players"):
		player = body # just in case
		animated_sprite_2d.play("Primed")
		$Area2D/CollisionShape2D.set_deferred("disabled", true) # prevent retriggering the timer
		primed_timer.start()

func _on_primed_timer_timeout():
	animated_sprite_2d.play("Ready")
	ready_timer.start()

func _on_ready_timer_timeout():
	var explosion = ENEMY_EXPLOSION.instantiate()
	explosion.damage = _enemy_stats.weapon_damage
	explosion.size = 0.9
	explosion.source = self
	explosion.modulate = "C05F21"
	call_deferred("create_child", explosion)
	Game.audio_manager.play(Game.audio_manager.bomb_pot_explosion)
	queue_free.call_deferred()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.animation == "Calm":
		return
	ding_SFX.play()
