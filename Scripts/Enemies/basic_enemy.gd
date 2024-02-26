extends CharacterBody2D

@onready var player := $"../Player"
var _enemy_stats: Object = enemy_stats.new()

func _ready():
	_enemy_stats.set_health(_enemy_stats.max_health)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.health_depleted.connect(die)

func _physics_process(delta):
	var direction = (player.global_position - self.global_position).normalized()
	velocity = direction * _enemy_stats.speed
	look_at(player.global_position)
	move_and_slide()

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players") and player.can_be_damaged:
		player._player_stats.take_damage(self._enemy_stats)
		
func die():
	process_mode = 4 # = Mode: Disabled
	# TODO: add death animation
	queue_free()
	
func update_health(new_health):
	_enemy_stats.health = new_health
	

