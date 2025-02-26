extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var lifetime = $Lifetime
@onready var bubble_pop_SFX = $BubblePop
@onready var bubble_fire_SFX = $BubbleFire

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

var spread: float
var size: float
var acceleration: float
var decel_threshold = 0.05

func _ready():
	super._ready()
	spread = deg_to_rad(randf_range(-20,20)) # random 20 degree spread
	size = randf_range(0.8, 1) # random sizes to immitate how bubbles work irl
	scale = Vector2.ONE * size
	acceleration = randf_range(0.75, 1) * RANGE / 200
	SfxDeconflicter.play(bubble_fire_SFX)
	deceleration.start(acceleration)

func update_position(delta):
	if deceleration.time_left > decel_threshold:
		current_velocity = direction.rotated(spread) * SPEED * deceleration.time_left
	else:
		current_velocity = direction.rotated(spread) * SPEED * decel_threshold
	position += current_velocity * delta

func _on_deceleration_timeout():
	lifetime.start()

func _on_lifetime_timeout():
	_collide.call_deferred(null)

func travelled_distance():
	pass

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	SfxDeconflicter.play(Game.audio_manager.bubble_pop)
	if body != null:
		has_collided.emit(body)
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(DAMAGE)
	weapon_direction = direction.rotated(spread)
	shoot_next_weapon()
	explode()
	queue_free.call_deferred()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.1 * SIZE
	splash.source = self
	splash.modulate = Color("87b950", 151.0/255)
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func shoot_next_weapon():
	if not randf() < 0.5:
		return
	super.shoot_next_weapon()
