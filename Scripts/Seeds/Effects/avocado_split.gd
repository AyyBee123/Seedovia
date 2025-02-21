extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

var tween
var angle_sign: float
var parent_direction: Vector2

func _ready():
	super._ready()
	look_at(parent_direction)
	tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", rotation + PI/2 * angle_sign, 0.3)
	tween.tween_property(self, "direction", Vector2.ZERO, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_callback(func():
		weapon_direction = parent_direction
		shoot_next_weapon()
		SfxDeconflicter.play(Game.audio_manager.crunch)
		SfxDeconflicter.play(Game.audio_manager.hit_2)
		explode()
		queue_free()
	)

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(player._player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	if tween:
		tween.kill()
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.crunch)
	explode()
	queue_free.call_deferred()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.45
	splash.source = self
	splash.modulate = Color("a8c445")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func travelled_distance():
	pass
