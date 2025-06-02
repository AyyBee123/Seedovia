extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const NUMBER_OF_SHOTS = 3

var rotation_offset: float
var rotate_dir

func _ready():
	super._ready()
	randomize()
	rotation_offset = randf_range(0, TAU)
	rotate_dir = -1 if randf() < 0.5 else 1

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.hit)
	
	explode()
	destroy()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta
	rotation += PI * delta * rotate_dir

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		explode()
		destroy()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.4 * SIZE
	splash.source = self
	splash.modulate = Color("9b3731")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func destroy():
	SfxDeconflicter.play(Game.audio_manager.sausage)
	for i in 3:
		weapon_direction = Vector2.RIGHT.rotated(TAU / NUMBER_OF_SHOTS * i + rotation_offset)
		shoot_next_weapon()
	super.destroy()
