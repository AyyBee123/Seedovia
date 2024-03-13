extends "res://Scripts/Seeds/seed_template.gd"

@onready var marker := $Branch/Marker2D
@onready var anim := $AnimationPlayer
@onready var lifetime := $Lifetime
@onready var hitbox := $Branch/Hitbox/CollisionShape2D
@onready var sprite := $Branch

var weapon = null
var source = player
static var swing_direction := true

func _ready():
	sprite.texture = self.texture
	if swing_direction:
		anim.play("Swing")
	else:
		anim.play("Swing Reverse")
	weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		if slot_index == 0:
			swing_direction = !swing_direction
			rotation = global_position.angle_to_point(get_global_mouse_position()) + deg_to_rad(90)
			lifetime.start(player.bullets_per_second.wait_time)
		else:
			swing_direction == true
			rotation = desired_direction.angle()
			lifetime.start(anim.current_animation_length)
		position_initialized = true

func travelled_distance():
	pass

func distance_after_collision():
	pass

func _collide(body):
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)

func update_position(delta):
	if slot_index == 0:
		global_position = player.global_position

func shoot_next_weapon(_weapon):
	if weapon == null:
		return
	var weapon_instance = weapon.instantiate()
	weapon_instance.initial_weapon = false
	weapon_instance.ignore_first_collision = false
	weapon_instance.slot_index = slot_index + 1
	weapon_instance.seed_slot_number = PlayerSeeds.seed_indices[seed_slot_number_index + 1]
	weapon_instance.seed_slot_number_index = seed_slot_number_index + 1
	weapon_instance.desired_direction = global_position.direction_to(marker.global_position)
	get_tree().current_scene.add_child(weapon_instance)
	weapon_fired.emit(weapon_instance)
	weapon_instance.global_position = marker.global_position

func _on_hitbox_area_entered(area):
	_collide(area)

func _on_hitbox_body_entered(body):
	_collide(body)

func end_of_animation():
	hitbox.disabled = true

func _on_lifetime_timeout():
	call_deferred("free")
