extends "res://Scripts/Bosses/boss.gd"

## y = 37 when changed to wall
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var _state_machine = $StateMachine
@onready var splat_2_SFX = $Splat2
@onready var splat_SFX = $Splat
@onready var stomp_SFX = $Stomp

var _can_move: bool = false: set = set_move
var direction: Vector2
var slimes := []
var number_of_slimes: int:
	get:
		return get_tree().get_nodes_in_group("Slime").size()

const SLIME = preload("res://Scenes/Enemies/Slime.tscn")
const JELLOFISH = preload("res://Scenes/Enemies/Jellofish.tscn")
const JELLO = preload("res://Scenes/Enemies/Jello.tscn")

const AMOUNT_OF_SLIMES = 4
const MAX_SLIMES = 3

func _ready():
	super._ready()
	$Shadow.visible = false
	slimes.append(SLIME)

func _physics_process(delta):
	super._physics_process(delta)

func idle():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	if player:
		direction = player.global_position - global_position

func jump():
	if _can_move:
		velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	else:
		velocity = Vector2.ZERO

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "Short Jump":
		if animated_sprite_2d.frame == 2:
			splat_2_SFX.play()
		if animated_sprite_2d.frame == 5:
			Targets.get_camera().add_trauma(0.3)
			stomp_SFX.play()
			splat_SFX.play()
			for i in AMOUNT_OF_SLIMES:
				var slime = slimes.pick_random().instantiate()
				slime.visible = false # gets rid of the single frame where the slime pops up on the screen
				slime.get_node("Enemy Hitbox/CollisionPolygon2D").disabled = true
				get_tree().current_scene.add_child(slime)
				slime.global_position = Vector2(randf_range(-750, 750), randf_range(-366, 366))
				slime._state_machine.set_state(slime._state_machine.states.spawn)
				await get_tree().create_timer(randf_range(0.05, 0.25)).timeout # add delay between spawns

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Short Jump":
		_state_machine.set_state(_state_machine.states.idle)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Jump":
		_state_machine.set_state(_state_machine.states.idle)

func set_move(value: bool):
	_can_move = value

func play_jump():
	splat_2_SFX.play()

func play_land():
	stomp_SFX.play()
	splat_SFX.play()
