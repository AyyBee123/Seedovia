extends "res://Scripts/Enemies/enemy.gd"

@onready var ding_SFX = $Ding

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var weapon_direction

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		# moves away from the player
		velocity = velocity.lerp(-player.global_position.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	
	move_and_slide()

func spawn_damage_number(damage: float):
	super.spawn_damage_number(damage)
	if damage >= _enemy_stats.health: # don't shoot if the next hit causes the mirror to die
		return
	
	var bullet = BULLET.instantiate()
	bullet.damage = _enemy_stats.weapon_damage
	bullet.range = _enemy_stats.weapon_range
	bullet.speed = _enemy_stats.weapon_speed
	bullet.direction = global_position.direction_to(player.global_position)
	get_tree().current_scene.add_child.call_deferred(bullet)
	bullet.global_position = global_position + bullet.direction * 10
	
	$AnimatedSprite2D.play("Shoot")
	SfxDeconflicter.play(ding_SFX)

func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.play("Idle")
