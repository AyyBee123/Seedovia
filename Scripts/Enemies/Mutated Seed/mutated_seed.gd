extends "res://Scripts/Enemies/enemy.gd"

@onready var fire_rate = $"Fire Rate"
@onready var pointer = $Pointer
@onready var marker_2d = $Pointer/Marker2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var crunch = $Crunch

const MUTATED_SEED_LEAF = preload("res://Scenes/Enemies/Weapons/Mutated Seed Leaf.tscn")

const OFFSET_POS = 10

var direction: Vector2
var rotation_speed: float = 2

func _ready():
	randomize()
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	
	if player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed * delta)

func idle():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.acceleration)

func chase():
	var dir = global_position.direction_to(marker_2d.global_position)
	velocity = velocity.lerp(dir * _enemy_stats.speed, _enemy_stats.acceleration)
	
	animated_sprite_2d.flip_h = dir.x > 0

func _on_fire_rate_timeout():
	crunch.play()
	var leaf_dir = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var leaf = MUTATED_SEED_LEAF.instantiate()
	leaf.damage = _enemy_stats.weapon_damage
	leaf.rotation = leaf_dir.angle()
	add_child(leaf)
	leaf.position += OFFSET_POS * leaf_dir
	fire_rate.start()
