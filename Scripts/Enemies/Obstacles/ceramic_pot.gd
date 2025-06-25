extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var plate_break = $PlateBreak
@onready var stomp = $Stomp
@onready var animated_sprite_2d = $AnimatedSprite2D

const ENEMY_EXPLOSION = preload("res://Scenes/Enemies/Weapons/Enemy Explosion.tscn")

var direction: Vector2
var rotation_direction: float

func _physics_process(delta):
	super._physics_process(delta)
	animated_sprite_2d.rotation += delta * TAU * rotation_direction
	velocity = direction * _enemy_stats.speed
	
	move_and_slide()

func set_direction():
	if player:
		direction = global_position.direction_to(player.global_position)
	
	rotation_direction = 1 if direction.x > 0 else -1

func explode():
	stomp.play()
	plate_break.play()
	var exp = ENEMY_EXPLOSION.instantiate()
	exp.damage = _enemy_stats.weapon_damage
	exp.size = 1.4
	exp.modulate = "95402f"
	exp.z_index = z_index
	get_tree().current_scene.add_child.call_deferred(exp)
	exp.global_position = global_position
