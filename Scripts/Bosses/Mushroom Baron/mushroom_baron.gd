extends "res://Scripts/Bosses/boss.gd"

@onready var spin_time = $"Spin Time"
@onready var air_time = $"Air Time"
@onready var spit_buildup_time = $"Spit Buildup Time"
@onready var spit_fire_rate = $"Spit Fire Rate"
@onready var resource_preloader = $ResourcePreloader
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var enemy_hitbox = $"Enemy Hitbox/CollisionPolygon2D"
@onready var enemy_damage_box = $"Enemy Damage Box/CollisionShape2D"
@onready var shadow = $Shadow
@onready var jump_SFX = $Jump
@onready var splat_SFX = $Splat

var spit_finished := false
var spin_finished := false
var jump_finished := false

var spin_direction: Vector2
var collision
var landing_position: Vector2
var shadow_size: Vector2

func _ready():
	super._ready()
	shadow_size = shadow.scale
	shadow.visible = false

func _physics_process(delta):
	super._physics_process(delta)
	collision = move_and_collide(velocity * delta)

func idle():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)

func spin():
	if animated_sprite_2d.animation == "Spin Beginning":
		spin_direction = global_position.direction_to(player.global_position)
	if animated_sprite_2d.animation == "Spin Middle":
		velocity = velocity.lerp(_enemy_stats.speed * spin_direction.normalized(), _enemy_stats.acceleration)
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			spin_direction = velocity
	if animated_sprite_2d.animation == "Spin End":
		velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)

func spit():
	if animated_sprite_2d.animation == "Spit Middle":
		if spit_fire_rate.is_stopped():
			var bullet_instance = resource_preloader.get_resource("Spore").instantiate()
			bullet_instance.damage = _enemy_stats.weapon_damage
			bullet_instance.range = _enemy_stats.weapon_range * randf_range(0.25, 1)
			bullet_instance.speed = _enemy_stats.weapon_speed
			bullet_instance.lifetime_amount = 8
			while bullet_instance.direction == Vector2.ZERO:
				bullet_instance.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			get_tree().current_scene.add_child(bullet_instance)
			bullet_instance.global_position = global_position + bullet_instance.direction * 25
			spit_fire_rate.start()

func jump():
	if animated_sprite_2d.animation == "Jump":
		if animated_sprite_2d.frame == 4:
			shadow.scale = Vector2.ZERO
		elif not animated_sprite_2d.visible:
			shadow.visible = true
			if air_time.time_left <= air_time.wait_time / 1.2:
				shadow.scale = shadow_size * (air_time.wait_time - air_time.time_left) / air_time.wait_time
	# fall animation
	else:
		shadow.scale = shadow_size

func _on_animated_sprite_2d_animation_finished():
	match animated_sprite_2d.animation:
		"Spin Beginning":
			animated_sprite_2d.play("Spin Middle")
			spin_time.start()
		"Spin End":
			spin_finished = true
		"Jump":
			animated_sprite_2d.visible = false
			air_time.start()
			# the player collision hitbox lands on the player's position, hence the added offset
			global_position = player.global_position + $"Enemy Hitbox/CollisionPolygon2D".position
		"Fall":
			shadow.visible = false
			jump_finished = true
		"Spit Beginning":
			animated_sprite_2d.play("Spit Middle")
			spit_buildup_time.start()
		"Spit End":
			spit_finished = true

func _on_spin_time_timeout():
	animated_sprite_2d.play("Spin End")

func _on_air_time_timeout():
	animated_sprite_2d.play("Fall")
	fall()

func _on_spit_buildup_time_timeout():
	animated_sprite_2d.play("Spit End")

func fall():
	pass

func _on_animated_sprite_2d_frame_changed():
	match animated_sprite_2d.animation:
		"Jump":
			if animated_sprite_2d.frame == 4:
				jump_SFX.play()
				enemy_hitbox.disabled = true
				enemy_damage_box.disabled = true
		"Fall":
			if animated_sprite_2d.frame == 2:
				enemy_hitbox.disabled = false
				enemy_damage_box.disabled = false
				splat_SFX.play()

func _on_animated_sprite_2d_animation_changed():
	if animated_sprite_2d.animation == "Fall":
		animated_sprite_2d.visible = true
