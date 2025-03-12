extends "res://Scripts/Enemies/enemy.gd"

@onready var ding_SFX = $Ding

const SEED_COLOR = preload("res://Shaders/seed_enemy_bullet_color.gdshader")

var seed
var original_seed
var seed_pos

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		# moves away from the player
		velocity = velocity.lerp(-player.global_position.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	
	move_and_slide()

func _on_enemy_hitbox_area_entered(area):
	if area.get_parent().is_in_group("Seed"):
		# get the seed and its position before hitting the mirror
		seed = area.get_parent().duplicate()
		original_seed = area.get_parent()
		seed_pos = original_seed.global_position

func spawn_damage_number(damage: float):
	super.spawn_damage_number(damage)
	if damage >= _enemy_stats.health: # don't shoot if the next hit causes the mirror to die
		return
	if original_seed:
		if is_instance_valid(original_seed):
			original_seed.queue_free.call_deferred()
		original_seed = null
	if seed: # reflect the seed, if applicable
		if is_instance_valid(seed):
			$AnimatedSprite2D.play("Shoot")
			instance_seed(seed, global_position.direction_to(seed_pos), global_position, null, SEED_COLOR)
			SfxDeconflicter.play(ding_SFX)
		seed = null
		seed_pos = null

func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.play("Idle")
