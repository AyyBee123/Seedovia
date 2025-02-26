extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const COIN = preload("res://Scenes/Coin/Coin.tscn")


const ROTATION_SPEED = 6
const COIN_CHANCE = 0.2

var _clockwise: bool

func _ready():
	randomize()
	super._ready()
	BASE_SIZE *= randf_range(0.75, 1)
	BASE_RANGE *= randf_range(0.95, 1.15)
	rotation = randf_range(0, TAU)
	_clockwise = randf() < 0.5

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta
	if _clockwise:
		rotation_degrees += ROTATION_SPEED
	else:
		rotation_degrees -= ROTATION_SPEED

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
		if not body.is_in_group("Dummy"):
			if randf() < COIN_CHANCE:
				var coin = COIN.instantiate()
				get_tree().current_scene.add_child(coin)
				coin.global_position = global_position
	SfxDeconflicter.play(Game.audio_manager.fools_gold)
	SfxDeconflicter.play(Game.audio_manager.hit)
	explode()
	queue_free.call_deferred()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.2
	splash.source = self
	splash.modulate = Color("ffdd33")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
