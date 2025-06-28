extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var yuck = $Yuck

const WORM_BULLET = preload("res://Scenes/Enemies/Weapons/Worm Bullet.tscn")

const NUMBER_OF_BULLETS = 6
const change_dir_chance = 0.01

var spawned_bullet_amount: int
var direction: Vector2

func _ready():
	randomize()
	super._ready()
	direction = Vector2(0, 1)

func _physics_process(delta):
	super._physics_process(delta)

func shoot():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	if animated_sprite_2d.animation != "Shoot":
		animated_sprite_2d.play("Shoot")

func idle():
	velocity = velocity.lerp(direction * _enemy_stats.speed, _enemy_stats.acceleration)
	
	if randf() <= change_dir_chance:
		set_random_direction()

func set_random_direction():
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var old_direction = direction
	var new_direction = directions.pick_random()
	
	if new_direction == Vector2.UP and not $"Detect Up".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	if new_direction == Vector2.DOWN and not $"Detect Down".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	if new_direction == Vector2.LEFT and not $"Detect Left".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	if new_direction == Vector2.RIGHT and not $"Detect Right".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	
	direction = new_direction
	
	match direction:
		Vector2.UP:
			play_anim("Back")
		Vector2.DOWN:
			play_anim("Front")
		Vector2.LEFT:
			play_anim("Side")
		Vector2.RIGHT:
			play_anim("Side")

func play_anim(anim: String):
	if animated_sprite_2d.animation != anim:
		var current_frame = animated_sprite_2d.get_frame()
		var current_progress = animated_sprite_2d.get_frame_progress()
		animated_sprite_2d.play(anim)
		animated_sprite_2d.set_frame_and_progress(current_frame, current_progress)
	animated_sprite_2d.flip_h = direction == Vector2.RIGHT

func _on_detect_up_body_entered(body):
	set_random_direction()

func _on_detect_down_body_entered(body):
	set_random_direction()

func _on_detect_right_body_entered(body):
	set_random_direction()

func _on_detect_left_body_entered(body):
	set_random_direction()

func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == "Shoot":
		spawned_bullet_amount += 1

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.animation == "Shoot":
		if animated_sprite_2d.frame == 3:
			yuck.play()
			# shoot worm projectile
			var bullet = WORM_BULLET.instantiate()
			bullet.damage = _enemy_stats.weapon_damage
			bullet.range = _enemy_stats.weapon_range
			bullet.speed = randf_range(150, 300)
			bullet.direction = global_position.direction_to(player.global_position).rotated(randf_range(-PI/2, PI/2))
			bullet.angle_multi = randf_range(2, 8)
			bullet.rotation_multi = randf_range(0.75, 1.5)
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = $"Enemy Hitbox/CollisionPolygon2D".global_position
