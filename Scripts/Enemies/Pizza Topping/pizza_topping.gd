extends "res://Scripts/Enemies/enemy.gd"

const FRAMES_TO_CHANGE_DIR: int = 16

var frames: int = 0
var direction: Vector2
var offset
var move_speed = 1

func _ready():
	randomize()
	super._ready()
	set_direction()
	offset = abs($AnimatedSprite2D.offset.x)

func _physics_process(delta):
	super._physics_process(delta)
	velocity = direction * _enemy_stats.speed * move_speed
	$AnimatedSprite2D.flip_h = direction.x > 0
	$AnimatedSprite2D.offset.x = sign(direction.x) * offset
	move_and_slide()

func set_direction():
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))

func die():
	SignalBus.topping_killed.emit()
	super.die()

func _on_animated_sprite_2d_frame_changed():
	if frames >= FRAMES_TO_CHANGE_DIR:
		set_direction()
		frames = 0
	else:
		frames += 1

func _on_lifetime_timeout():
	move_speed = 0
	$"Enemy Hitbox/CollisionPolygon2D".disabled = true
	$AnimatedSprite2D.play("Leave")

func _on_animated_sprite_2d_animation_finished():
	SignalBus.topping_saved.emit()
	queue_free()
