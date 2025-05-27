extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

@onready var tick_rate = $"Tick Rate"
@onready var lifetime = $Lifetime

const SPREAD = PI/6

var is_stuck: bool
var is_stuck_to_enemy: bool
var distance_to_enemy: Vector2
var enemy
var enemy_hitbox

func _physics_process(delta):
	player = Targets.get_player()
	if not is_stuck:
		travelled_distance()
	update_position(delta)
	set_ignore_first_collision()
	visible = true

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		is_stuck_to_enemy = true
		enemy = body.get_parent()
		enemy_hitbox = body
		distance_to_enemy = enemy.global_position - global_position
	if body.is_in_group("Players"):
		body._player_stats.take_damage(1)
		explode()
		destroy()
	is_stuck = true
	lifetime.start()

func update_position(delta):
	if not is_stuck:
		super.update_position(delta)
	else:
		BASE_SPEED = 0
		if is_stuck_to_enemy:
			if not is_instance_valid(enemy):
				destroy()
				return
			global_position = enemy.global_position - distance_to_enemy
			if tick_rate.is_stopped():
				has_collided.emit(enemy_hitbox) # for on-hit effects (ex: burning an enemy on hit)
				enemy._enemy_stats.take_damage(DAMAGE)
				SfxDeconflicter.play(Game.audio_manager.hit_2)
				shoot_next_weapon()
				if get_next_weapon():
					tick_rate.start(1.0 / get_next_weapon().instantiate().FIRE_RATE)
				else:
					tick_rate.start(1.0 / FIRE_RATE)

func shoot_next_weapon():
	weapon_direction = -direction.rotated(randf_range(-SPREAD, SPREAD))
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func _on_lifetime_timeout():
	explode()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.333 * SIZE
	splash.source = self
	if shader:
		splash.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		splash.get_node("AnimatedSprite2D").material.shader = shader
	splash.modulate = Color("951f1f")
	call_deferred("create_child", splash)

func create_child(child):
	SfxDeconflicter.play(Game.audio_manager.hit)
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
	destroy()
