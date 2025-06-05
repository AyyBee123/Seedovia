extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $state_machine
@onready var pos_1 = $Pos1
@onready var pos_2 = $Pos2
@onready var pos_3 = $Pos3
@onready var bubble_pop_2_SFX = $BubblePop2
@onready var hit_SFX = $Hit2
@onready var splat_SFX = $Splat2

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const SPREAD_3 = PI/6
const SPREAD_2 = PI/4
const SPREAD_1 = PI/3

var speed_boost: float
var NUMBER_OF_SCOOPS: int = 3
var pos: Vector2
var direction: Vector2

func _ready():
	randomize()
	super._ready()

func idle():
	if player:
		direction = global_position.direction_to(player.global_position)
	velocity = (_enemy_stats.speed + speed_boost) * direction

func die():
	velocity = Vector2.ZERO
	if NUMBER_OF_SCOOPS - 1 > 0:
		_state_machine.set_state(_state_machine.states.die)
		_enemy_stats.heal(_enemy_stats.max_health)
		animated_sprite_2d.play(str(NUMBER_OF_SCOOPS) + " to " + str(NUMBER_OF_SCOOPS - 1))
		speed_boost += 25
		NUMBER_OF_SCOOPS -= 1
		bubble_pop_2_SFX.play()
		hit_SFX.play()
	else:
		process_mode = 4 # = Mode: Disabled
		queue_free.call_deferred()

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.frame >= 10:
		splat_SFX.play()
		var bullet = BULLET.instantiate()
		match animated_sprite_2d.animation:
			"3 Scoop":
				match animated_sprite_2d.frame:
					10:
						pos = pos_1.global_position
						bullet.direction = direction.rotated(-SPREAD_3)
					11:
						pos = pos_2.global_position
						bullet.direction = direction
					12:
						pos = pos_3.global_position
						bullet.direction = direction.rotated(SPREAD_3)
			"2 Scoop":
				match animated_sprite_2d.frame:
					10:
						pos = pos_1.global_position
					11:
						pos = pos_2.global_position
				bullet.direction = direction.rotated(randf_range(-SPREAD_2, SPREAD_2))
			"1 Scoop":
				pos = pos_1.global_position
				bullet.direction = direction.rotated(randf_range(-SPREAD_1, SPREAD_1))
		
		shoot(bullet)

func shoot(bullet):
	bullet.damage = _enemy_stats.weapon_damage
	bullet.range = _enemy_stats.weapon_range
	bullet.speed = _enemy_stats.weapon_speed
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = pos
