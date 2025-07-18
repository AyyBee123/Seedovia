extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const SLOW = preload("res://Scenes/Seeds/Effects/Slow.tscn")

const ROTATION_SPEED = PI

var rotation_direction: float = 1
var tween
var target

func _ready():
	randomize()
	super._ready()
	rotation_direction = -1 if randf() < 0.5 else 1

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta
	rotation += PI * rotation_direction * delta

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		desolve()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	SfxDeconflicter.play(Game.audio_manager.ice_crack)
	explode()
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
		slow(body.get_parent())
	elif body.is_in_group("Obstacle"):
		slow(body.get_parent())
	else:
		destroy()

func explode():
	SfxDeconflicter.play(Game.audio_manager.slow)
	var splash = SPLASH.instantiate()
	splash.size = 0.25 * SIZE
	splash.source = self
	splash.modulate = Color("b5e3de")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func initialize_location(weapon):
	if not get_tree():
		return
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	if not target:
		target = self
	weapon.global_position = target.global_position

func slow(enemy):
	target = enemy
	var slow
	if enemy.get_node_or_null("Slow"):
		slow = enemy.get_node("Slow")
	else:
		slow = SLOW.instantiate()
		enemy.add_child(slow)
	var stacks = slow.stacks
	if slow.stacks >= int(1.0 / slow.SLOW_FACTOR):
		for i in 8:
			weapon_direction = Vector2.RIGHT.rotated(TAU / 8 * i)
			shoot_next_weapon()
	slow.slow()

func desolve():
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.25)
	tween.tween_callback(destroy)

func destroy():
	SeedManager.seeds_on_screen.erase(self)
	queue_free.call_deferred()

func _exit_tree():
	if tween:
		tween.kill()
