extends "res://Scripts/Bosses/boss.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var fire_rate = $"Fire Rate"
@onready var pot_spawn = $"Pot Spawn"
@onready var stomp_SFX = $Stomp

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")
const POT_BULLET = preload("res://Scenes/Enemies/Weapons/Pot Bullet.tscn")
const LOBBED_POT = preload("res://Scenes/Enemies/Weapons/Lobbed Pot.tscn")

const SPIT_AMOUNT = 1
const JUMP_AMOUNT = 6
const JUMP_NUMBER_OF_PROJECTILES = 24

var jumps: int
var spits: int

func _ready():
	randomize()
	super._ready()

func _on_fire_rate_timeout():
	var bullet = LOBBED_POT.instantiate()
	bullet.damage = _enemy_stats.weapon_damage
	bullet.range = _enemy_stats.weapon_range
	bullet.speed = _enemy_stats.weapon_speed * 1.5
	bullet.pos = Vector2(randf_range(-764, 764), randf_range(-380, 380))
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = pot_spawn.global_position
	Game.audio_manager.play(Game.audio_manager.sausage_2)
	fire_rate.start()

func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == "Jump":
		jumps += 1
	
	if animated_sprite_2d.animation == "Spit":
		var bullet = POT_BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed * 1.5
		bullet.direction = global_position.direction_to(player.global_position)
		Game.audio_manager.play(Game.audio_manager.sausage_3)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + bullet.direction * 50
		spits += 1

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.animation == "Jump":
		if animated_sprite_2d.frame == 2:
			Game.audio_manager.play(Game.audio_manager.rock_4)
			stomp_SFX.play()
			Targets.get_camera().add_trauma(0.2)
			var spread = 0 if jumps % 2 == 0 else TAU / (JUMP_NUMBER_OF_PROJECTILES * 2)
			for i in JUMP_NUMBER_OF_PROJECTILES:
				var bullet = BULLET.instantiate()
				bullet.damage = _enemy_stats.weapon_damage
				bullet.range = _enemy_stats.weapon_range
				bullet.speed = _enemy_stats.weapon_speed
				bullet.direction = Vector2.RIGHT.rotated(TAU / JUMP_NUMBER_OF_PROJECTILES * i + spread)
				get_tree().current_scene.add_child(bullet)
				bullet.global_position = global_position + bullet.direction * 25
