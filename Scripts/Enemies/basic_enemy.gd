extends CharacterBody2D

var player
@export var _enemy_stats: enemy_stats

func _ready():
	_enemy_stats.initialize_stats(_enemy_stats)
	_enemy_stats.set_health(_enemy_stats.max_health)
	
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.health_depleted.connect(die)

func _physics_process(delta):
	var direction = (player.global_position - self.global_position).normalized()
	velocity = direction * _enemy_stats.speed
	look_at(player.global_position)
	move_and_slide()

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(self._enemy_stats.damage)
		
func die():
	process_mode = 4 # = Mode: Disabled
	# TODO: add death animation
	self.queue_free()
	
func update_health(new_health):
	_enemy_stats.health = new_health
	
