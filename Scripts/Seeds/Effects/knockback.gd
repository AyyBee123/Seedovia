extends Node

@onready var impulse_time = $"Impulse Time"
@onready var deceleration_time = $"Deceleration Time"
@onready var hit_SFX = $Hit

var knockback_direction: Vector2
var knockback_speed: float
var enemy
var damage
var _took_damage := false

func _ready():
	enemy = get_parent()

func _physics_process(delta):
	var collision
	if deceleration_time.is_stopped():
		enemy.velocity = knockback_direction * knockback_speed
		collision = enemy.move_and_collide(enemy.velocity * delta)
	else:
		enemy.velocity = knockback_direction * knockback_speed * deceleration_time.time_left \
		/ deceleration_time.wait_time
		collision = enemy.move_and_collide(enemy.velocity * delta)
	if collision:
		enemy.velocity = enemy.velocity.bounce(collision.get_normal())
		if not _took_damage:
			enemy._enemy_stats.take_damage(damage)
			_took_damage = true
			SfxDeconflicter.play(hit_SFX)
			if hit_SFX.playing:
				await hit_SFX.finished
			enemy.remove_child(self)
			queue_free.call_deferred()

func _on_impulse_time_timeout():
	if deceleration_time.is_stopped():
		deceleration_time.start()

func _on_deceleration_time_timeout():
	if hit_SFX.playing:
		await hit_SFX.finished
	enemy.remove_child(self)
	queue_free.call_deferred()
