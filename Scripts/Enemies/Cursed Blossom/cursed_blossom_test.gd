extends "res://Scripts/Enemies/enemy.gd"

@onready var fire_rate = $"Fire Rate"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var SEED_ENEMY_BULLET_COLOR = preload("res://Shaders/seed_enemy_bullet_color.gdshader")

const BULLET = preload("res://Scenes/Seeds/Wood Thorn.tscn")

var direction: Vector2

func _ready():
	super._ready()
	randomize()
	fire_rate.start(randf_range(1.5, 2))

func _physics_process(delta):
	super._physics_process(delta)
	direction = global_position.direction_to(player.global_position)

func _on_animated_sprite_2d_animation_changed():
	if animated_sprite_2d.animation == "Shoot":
		var bullet = BULLET.instantiate()
		bullet.initial_weapon = true
		bullet.desired_direction = direction
		bullet.previous_weapon = self
		bullet.source = self
		bullet.slot_index = 3
		bullet.seed_slot_number = 3
		bullet.collisions = 3
		bullet.target_group = "Players"
		bullet.shader = SEED_ENEMY_BULLET_COLOR
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + direction * 5
		fire_rate.start(1.0 / bullet.FIRE_RATE * 2)

func _on_fire_rate_timeout():
	animated_sprite_2d.play("Shoot")

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("Idle")
