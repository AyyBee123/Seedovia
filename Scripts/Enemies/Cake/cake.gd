extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var cake_collision_shape = $CakeCollisionShape
@onready var cake_hitbox = $"Cake Hitbox/CollisionShape2D"
@onready var drop_SFX = $Drop
@onready var heal_1 = $Heal
@onready var heal_2 = $Heal2
@onready var heal_3 = $Heal3
@onready var sound_delay = $"Sound Delay"

var number_of_sounds: int = 0

const BULLETS = {
	0: preload("res://Scenes/Enemies/Weapons/Cake Bullet 1.tscn"),
	1: preload("res://Scenes/Enemies/Weapons/Cake Bullet 2.tscn"),
	2: preload("res://Scenes/Enemies/Weapons/Cake Bullet 3.tscn"),
	3: preload("res://Scenes/Enemies/Weapons/Cake Bullet 4.tscn"),
}

var angle = PI/8
var number_of_slices: int = 0

func idle():
	if player:
		velocity = global_position.direction_to(player.global_position) * _enemy_stats.speed
	
	move_and_slide()

func fire():
	drop_SFX.play()
	
	shoot_cake(0)
	shoot_cake(1)
	shoot_cake(2)
	shoot_cake(3)
	shoot_cake(3)
	shoot_cake(2)
	shoot_cake(1)
	shoot_cake(0)

func shoot_cake(cake_index):
	var bullet = BULLETS[cake_index].instantiate()
	bullet.damage = _enemy_stats.weapon_damage
	bullet.speed = _enemy_stats.weapon_speed
	bullet.range = _enemy_stats.weapon_range
	bullet.direction = Vector2.DOWN.rotated(angle)
	bullet.source = self
	bullet.scale = scale
	if bullet.direction.x < 0:
		bullet.flip_h = true
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + bullet.direction * 12
	angle += PI/4

func _on_sound_delay_timeout():
	if number_of_sounds >= 2:
		number_of_sounds = 0
		return
	number_of_sounds += 1
	get("heal_" + str(number_of_sounds + 1)).play()
	sound_delay.start()
