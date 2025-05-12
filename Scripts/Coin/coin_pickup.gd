extends Node2D

const SPARKLE = preload("res://Scenes/Misc/Sparkle.tscn")

var player

func _ready():
	for i in 4:
		spawn_sparkle(Color("edb800"))

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
	for i in 4:
		player.spawn_sparkle(Color("edb800"))
	Game.audio_manager.play(Game.audio_manager.coin)
	queue_free()

func spawn_sparkle(color: Color):
	var sparkle = SPARKLE.instantiate()
	sparkle.modulate = color
	sparkle.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	add_child(sparkle)
	sparkle.global_position = global_position + sparkle.direction * 20
