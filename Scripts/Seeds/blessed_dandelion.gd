extends "res://Scripts/Seeds/seed_template.gd"

@onready var fire_rate = $"Fire Rate"
@onready var lifetime = $Lifetime

const DANDELION_FIRE_RATE = 0.5

var angle := 0.0
var radius: float
var current_radius := 0.0
var mouse_left_down := true
var _released := false
var tween

func _ready():
	super._ready()
	radius = 50 * SIZE
	fire_rate.start(randf_range(0, 1))
	angle = desired_direction.angle() / SPEED * 50

func _physics_process(delta):
	update_position(delta)
	set_ignore_first_collision()

func update_position(delta):
	if previous_weapon == player and not _released:
		if mouse_left_down:
			orbit(delta)
		else:
			launch(delta)
	else:
		if is_instance_valid(previous_weapon) and not _released:
			orbit(delta)
		else:
			launch(delta)

func orbit(delta):
	angle += delta
	tween = get_tree().create_tween()
	tween.tween_property(self, "current_radius", radius, \
			1.0 / (SPEED / 50))
	var speed = SPEED / 50
	global_position = Vector2(
		sin(angle * speed) * current_radius,
		cos(angle * speed) * current_radius
	) + previous_weapon.global_position
	direction = previous_weapon.global_position.direction_to(global_position)
	if fire_rate.is_stopped() and tween.finished:
		shoot_next_weapon()

func launch(delta):
	if not _released:
		_released = true
		starting_position = global_position
	travelled_distance()
	
	current_velocity = direction * SPEED
	position += current_velocity * delta

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	var weapon_instance = get_next_weapon().instantiate()
	
	if direction == Vector2.ZERO: # direction is sometimes zero
		direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	weapon_direction = direction
	fire_rate.start(1.0 / (DANDELION_FIRE_RATE * get_next_weapon().instantiate().FIRE_RATE))
	set_weapon_properties(weapon_instance, weapon_direction)

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.blessed_dandelion_hit)
	queue_free.call_deferred()

func _input(event):
	if Input.is_action_just_pressed("shoot") and event.is_pressed():
			mouse_left_down = true
	elif Input.is_action_just_released("shoot") and not event.is_pressed():
			mouse_left_down = false

func _on_lifetime_timeout():
	_released = true
