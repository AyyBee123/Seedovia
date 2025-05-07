extends Node2D

var player

func _physics_process(delta):
	if player != null:
		position += global_position.direction_to(player.global_position) * delta * 600

func _on_attract_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body

func _on_pickup_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		pick_up()

func pick_up():
	player._player_stats.set_coins(1)
	player.get_node("Player Health").set_coins()
	Game.audio_manager.play(Game.audio_manager.coin)
	queue_free()
