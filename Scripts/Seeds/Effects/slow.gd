extends Node

@onready var duration = $Duration

const SLOW_SPRITE = preload("res://Scenes/Seeds/Effects/Slow Sprite.tscn")
const NON_WEAPON_EFFECT_EXPLOSION = preload("res://Scenes/Passives/Effects/Non-Weapon Effect Explosion.tscn")

const SLOW_FACTOR = 0.25
const DAMAGE = 20
const BLAST_RADIUS = 1.75

var stacks: int = 0
var normal_speed: float
var normal_animation_speed: float
var normal_color
var enemy
var is_frozen: bool
var sprite

func _ready():
	enemy = get_parent()
	normal_speed = enemy._enemy_stats.speed
	normal_animation_speed = enemy.get_node("AnimatedSprite2D").speed_scale
	sprite = SLOW_SPRITE.instantiate()
	enemy.add_child(sprite)

func slow():
	#check if enemy is frozen
	if is_frozen:
		# explode
		is_frozen = false
		# make a sound
		explode()
		SfxDeconflicter.play(Game.audio_manager.glass_break)
		SfxDeconflicter.play(Game.audio_manager.shatter)
		queue_free()
		return
	
	duration.start() # reset the slow duration
	stacks += 1 # add 1 stack of slow (makes the enemy slower)
	enemy._enemy_stats.speed *= (1 - SLOW_FACTOR * stacks) # slow down enemy's movement speed
	enemy.get_node("AnimatedSprite2D").speed_scale *= (1 - SLOW_FACTOR * stacks) # slow down the enemy's animation speed
	if sprite:
		sprite.material.set("shader_parameter/fade", stacks * (SLOW_FACTOR - 0.05))
	if stacks >= int(1.0 / SLOW_FACTOR):
		# freeze the enemy
		SfxDeconflicter.play(Game.audio_manager.freeze)
		enemy.get_node("AnimatedSprite2D").pause()
		duration.start(4)
		is_frozen = true

func explode():
	var explosion = NON_WEAPON_EFFECT_EXPLOSION.instantiate()
	if get_node_or_null("Passives"):
		for passive in $Passives.get_children():
			explosion.get_node("Passives").add_child(passive.duplicate())
	var stat = Targets.get_player()._player_stats.stats
	explosion.BASE_DAMAGE = DAMAGE * (1 + stat["Weapon_Damage"]["+"]) * stat["Weapon_Damage"]["x"]
	explosion.BASE_SIZE = BLAST_RADIUS * (1 + stat["Weapon_Blast_Radius"]["+"]) * stat["Weapon_Blast_Radius"]["x"]
	explosion.get_node("AnimatedSprite2D").self_modulate = Color("b5e3de")
	call_deferred("create_child", explosion)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = enemy.global_position

func _on_duration_timeout():
	queue_free()

func _exit_tree():
	enemy._enemy_stats.speed = normal_speed
	enemy.get_node("AnimatedSprite2D").speed_scale = normal_animation_speed
	enemy.get_node("AnimatedSprite2D").play()
	if sprite:
		sprite.queue_free()
