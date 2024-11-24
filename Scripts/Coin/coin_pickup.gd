extends Node2D

var player
var _is_in_area: bool

func _physics_process(delta):
	if player != null and _is_in_area:
		position += global_position.direction_to(player.global_position) * delta * 600

func _on_attract_area_body_entered(body):
	if body.is_in_group("Players"):
		_is_in_area = true
		player = body

func _on_pickup_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		pick_up()

func pick_up():
	player._player_stats.set_coins(1)
	player.get_node("Player Health").set_coins()
	queue_free()
