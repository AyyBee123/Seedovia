extends "res://Scripts/Enemies/enemy.gd"

@onready var sound_timer = $"Sound Timer"
@onready var chicken_SFX = $Chicken
@onready var hit_SFX = $Hit2
@onready var bubble_pop_SFX = $BubblePop2

const EGG_BULLET = preload("res://Scenes/Enemies/Weapons/Egg Bullet.tscn")

const FRAMES_TO_CHANGE_DIR: int = 9
const SPREAD := PI/6
const OFFSET: float = 22

var frames: int = 0
var direction: Vector2
var offset

func _ready():
	randomize()
	super._ready()
	set_direction()
	sound_timer.start(randf_range(3, 6))
	offset = abs($AnimatedSprite2D.offset)

func _physics_process(delta):
	super._physics_process(delta)
	velocity = direction * _enemy_stats.speed
	$AnimatedSprite2D.flip_h = direction.x > 0
	$AnimatedSprite2D.offset = sign(direction.x) * offset
	move_and_slide()

func set_direction():
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))

func _on_animated_sprite_2d_frame_changed():
	if frames >= FRAMES_TO_CHANGE_DIR:
		set_direction()
		frames = 0
	else:
		frames += 1

func _on_animated_sprite_2d_animation_looped():
	hit_SFX.play()
	bubble_pop_SFX.play()
	
	var egg = EGG_BULLET.instantiate()
	egg.damage = _enemy_stats.damage
	egg.range = _enemy_stats.weapon_range
	egg.speed = _enemy_stats.weapon_speed
	egg.direction = Vector2(sign(-direction.x), randf_range(-SPREAD, SPREAD)).normalized()
	get_tree().current_scene.add_child(egg)
	egg.global_position = global_position - Vector2(OFFSET * sign(direction.x), 0)

func _on_sound_timer_timeout():
	chicken_SFX.play()
	sound_timer.start(randf_range(4, 8))
