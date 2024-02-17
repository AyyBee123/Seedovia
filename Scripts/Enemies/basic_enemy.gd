extends CharacterBody2D

@onready var player := $"../Player"
var _enemy_stats: Object = enemy_stats.new()

var health = _enemy_stats.max_health
var speed = _enemy_stats.speed
var fire_rate = _enemy_stats.fire_rate
var damage = _enemy_stats.damage

func _physics_process(delta):
	var direction = (player.global_position - self.global_position).normalized()
	velocity = direction * speed
	look_at(player.global_position)
	move_and_slide()
	
	if health <= 0:
		_die()

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players") and player.can_be_damaged:
		body.health -= damage
		
func _die():
	# TODO: add death animation and disable damage to player
	queue_free()
	
