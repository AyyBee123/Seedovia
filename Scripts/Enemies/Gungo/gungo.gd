extends "res://Scripts/Enemies/enemy.gd"

@onready var marker_2d = $Marker2D
@onready var fire_rate = $"Fire Rate"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var burp_SFX = $Burp
@onready var thud_SFX = $Thud

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var direction: Vector2

func _ready():
	super._ready()
	fire_rate.start(1.0/_enemy_stats.fire_rate)

func _physics_process(delta):
	super._physics_process(delta)
	
	direction = global_position.direction_to(player.global_position).normalized()
	
	if player:
		if player.global_position > global_position: # to the right of Gungo
			animated_sprite_2d.flip_h = true
			marker_2d.position.x = 4
		else:
			animated_sprite_2d.flip_h = false
			marker_2d.position.x = -4
	
	if animated_sprite_2d.animation == "Idle":
		velocity = velocity.lerp(direction * _enemy_stats.speed, _enemy_stats.friction)
	
	move_and_slide()

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("Idle")
	fire_rate.start(1.0/_enemy_stats.fire_rate)

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.animation == "Shoot":
		if animated_sprite_2d.frame == 4:
			var bullet_direction = marker_2d.global_position.direction_to(player.global_position).normalized()
			var angles = [-PI/6, 0, PI/6]
			for i in angles:
				var bullet_instance = BULLET.instantiate()
				bullet_instance.damage = _enemy_stats.weapon_damage
				bullet_instance.range = _enemy_stats.weapon_range
				bullet_instance.speed = _enemy_stats.weapon_speed
				bullet_instance.direction = bullet_direction.rotated(i)
				get_tree().current_scene.add_child(bullet_instance)
				bullet_instance.global_position = marker_2d.global_position
			velocity = -direction * _enemy_stats.speed * 10
			thud_SFX.play()
			burp_SFX.play()

func _on_fire_rate_timeout():
	animated_sprite_2d.play("Shoot")
