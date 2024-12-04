extends "res://Scripts/Seeds/seed_template.gd"

@onready var beginning = $"Cheese Beginning"
@onready var middle = $"Cheese Middle"
@onready var end = $"Cheese End"
@onready var marker_2d = $"Cheese End/Marker2D"
@onready var collision_shape_2d = $Hitbox/CollisionShape2D
@onready var animation_end_lifetime = $"Animation end lifetime"
@onready var resource_preloader = $ResourcePreloader
@onready var bonk_SFX = $Bonk
@onready var smack_SFX = $Smack

var _was_previous_weapon
var t = 0.0
var rect_width = 0.0
var mouse_left_down := true
var angle_threshold: float = 150.0 # angle in degrees
var starting_angle: float = 0.0
var angle_travelled: float = 0.0
var total_angle: float = 0.0
var _initial_shot := true # this is to prevent a seed from firing immediately when spawning the cheese
var starting_rotation: float = 75.0

func _ready():
	if previous_weapon != player: # if fired by a non-player
		_was_previous_weapon = true
		_initial_shot = false
		rotation_degrees = rad_to_deg(desired_direction.angle()) - starting_rotation
		angle_threshold = angle_threshold / (player._player_stats.get_stat("Fire_Rate") * fire_rate_multiplier * 1.7)
	else:
		if name != "Cheese":
			queue_free()
		angle_threshold = angle_threshold / (player._player_stats.get_stat("Fire_Rate") * fire_rate_multiplier)
	super._ready()
	set_variable_sizes()
	starting_position = global_position
	starting_angle = rotation_degrees
	angle_travelled = 0.0
	direction = desired_direction.normalized()
	if not _was_previous_weapon: # if fired by the player
		rotation = global_position.angle_to_point(player.weapon_direction_marker.global_position)
	else:
		rotation_degrees = rad_to_deg(desired_direction.angle()) - starting_rotation

func _physics_process(delta):
	super._physics_process(delta)
	t += delta * 2.5
	set_variable_sizes()
	if not _was_previous_weapon: # if fired from the player
		rect_width = min(player._player_stats.get_stat("Weapon_Range") \
				 * range_multiplier * t, player._player_stats.get_stat("Weapon_Range") * range_multiplier)
		if not mouse_left_down:
			queue_free()
	else:
		rect_width = player._player_stats.get_stat("Weapon_Range") * range_multiplier
		animate()
	rotation_travelled()

func rotation_travelled():
	angle_travelled = rotation_degrees - starting_angle
	total_angle += abs(angle_travelled)
	starting_angle = rotation_degrees
	if total_angle >= angle_threshold:
		total_angle = 0.0
		if not _initial_shot:
			weapon_direction = Vector2.RIGHT.rotated(rotation)
			shoot_next_weapon()
		else:
			_initial_shot = false

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	weapon.global_position = marker_2d.global_position

func set_variable_sizes():
	middle.region_rect = Rect2(0, 0, rect_width, middle.get_region_rect().size.y)
	collision_shape_2d.shape.size.x = beginning.texture.get_width() + middle.get_region_rect().size.x
	collision_shape_2d.position.x = collision_shape_2d.shape.size.x / 2
	end.position.x = end.texture.get_width() + middle.get_region_rect().size.x

func _collide(body):
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		var knockback_angle = rotation + PI/2 * sign(angle_travelled)
		var knockback_direction = Vector2.RIGHT.rotated(knockback_angle).normalized()
		var damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier * abs(angle_travelled) / 10
		if _was_previous_weapon:
			damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier * 3
		if damage < 1: # do nothing if the damage is a very small amount
			return
		body.get_parent()._enemy_stats.take_damage(damage)
		if randi_range(1, 100) == 100: # 1 in 100 chance to play a bonk SFX
			SfxDeconflicter.play(bonk_SFX)
		else:
			SfxDeconflicter.play(smack_SFX)
		# add a node to the enemy that knocks them back when hit by the block of cheese
		var knockback_scene = resource_preloader.get_resource("Knockback").instantiate()
		knockback_scene.knockback_direction = knockback_direction
		knockback_scene.knockback_speed = abs(angle_travelled) * 50
		knockback_scene.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
		if not body.get_parent().find_child(knockback_scene.name):
			# add node to the enemy that gives velocity/position change and makes them take damage if they hit a wall
			body.get_parent().add_child(knockback_scene)

func update_position(delta):
	if not _was_previous_weapon:
		global_position = player.hand.global_position
		rotation = global_position.angle_to_point(player.weapon_direction_marker.global_position)

func animate():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"rotation_degrees", rad_to_deg(desired_direction.angle()) + starting_rotation, 0.075)
	tween.finished.connect(destroy)

func destroy():
	if animation_end_lifetime.is_stopped():
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		animation_end_lifetime.start()

func travelled_distance():
	pass

func _input(event):
	if Input.is_action_just_pressed("shoot") and event.is_pressed():
			mouse_left_down = true
	elif Input.is_action_just_released("shoot") and not event.is_pressed():
			mouse_left_down = false

func _on_animation_end_lifetime_timeout():
	queue_free.call_deferred()
