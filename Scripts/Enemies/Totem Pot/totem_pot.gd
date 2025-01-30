extends "res://Scripts/Enemies/enemy.gd"

@onready var idle_time = $"Idle Time"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var charge_up_SFX = $ChargeUp2
@onready var launch_SFX = $Launch

const TOTEM_BULLET = preload("res://Scenes/Enemies/Weapons/Totem Bullet.tscn")
const ANGLE = PI/6
const ANGLE_CHANGE = PI/72

var IDLE_TIME
var angle := 0.0

func _ready():
	super._ready()
	IDLE_TIME = idle_time.wait_time
	randomize()
	idle_time.start(randf_range(2, 3))

func _on_idle_time_timeout():
	animated_sprite_2d.play("Charge")
	if not charge_up_SFX.playing:
		charge_up_SFX.play()

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("Idle")
	idle_time.start(IDLE_TIME)

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "Charge":
		if $AnimatedSprite2D.frame == 21: # the spit frame
			charge_up_SFX.stop()
			launch_SFX.play()
			while angle <= ANGLE:
				var bullet = TOTEM_BULLET.instantiate()
				var direction = $Marker2D.global_position.direction_to(player.global_position)
				bullet.direction = Vector2.RIGHT.rotated(angle - ANGLE / 2 + direction.angle())
				bullet.speed = _enemy_stats.weapon_speed
				bullet.range = _enemy_stats.weapon_range
				get_tree().current_scene.add_child(bullet)
				bullet.global_position = $Marker2D.global_position
				angle += ANGLE_CHANGE
			angle = 0
