extends Sprite2D

@onready var damage_buffer = $"Damage Buffer"

var player
var is_in_area: bool

func _physics_process(delta):
	if player == null: # keep looking for the player until they are found
		player = Targets.get_player()
	if is_in_area and damage_buffer.is_stopped() and get_parent().get_parent()._enemy_stats.damage > 0:
		player._player_stats.take_damage(get_parent().get_parent()._enemy_stats.damage)
		damage_buffer.start()
	
	rotation = -get_parent().rotation

func _on_spike_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player = body # just in case
		is_in_area = true

func _on_spike_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false
