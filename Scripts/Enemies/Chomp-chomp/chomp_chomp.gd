extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var bite_SFX = $Bite2

const HOLE = preload("res://Scenes/Enemies/Effects/Hole.tscn")

const change_dir_chance = 0.01

var direction: Vector2
var offset: float
var collision_pos: float

func _ready():
	super._ready()
	direction = Vector2(-1, 0)
	offset = abs(animated_sprite_2d.offset.x)
	collision_pos = abs(%Side.position.x)
	%Up.disabled = true
	%Down.disabled = true
	randomize()

func _physics_process(delta):
	super._physics_process(delta)
	
	velocity = direction * _enemy_stats.speed
	
	if randf() <= change_dir_chance:
		set_random_direction()
	
	move_and_slide()

func set_random_direction():
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var old_direction = direction
	var new_direction = directions.pick_random()
	
	if new_direction == Vector2.UP and not $"Detect Up".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	if new_direction == Vector2.DOWN and not $"Detect Down".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	if new_direction == Vector2.LEFT and not $"Detect Left".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	if new_direction == Vector2.RIGHT and not $"Detect Right".get_overlapping_bodies().is_empty():
		set_random_direction()
		return
	
	direction = new_direction
	
	match direction:
		Vector2.UP:
			play_anim("Up")
		Vector2.DOWN:
			play_anim("Down")
		Vector2.LEFT:
			play_anim("Side")
		Vector2.RIGHT:
			play_anim("Side")

func play_anim(anim: String):
	if animated_sprite_2d.animation != anim:
		var current_frame = animated_sprite_2d.get_frame()
		var current_progress = animated_sprite_2d.get_frame_progress()
		animated_sprite_2d.play(anim)
		animated_sprite_2d.set_frame_and_progress(current_frame, current_progress)
	animated_sprite_2d.flip_h = direction == Vector2.RIGHT
	if animated_sprite_2d.flip_h:
		animated_sprite_2d.offset.x = offset
		%Side.position.x = collision_pos
	else:
		animated_sprite_2d.offset.x = -offset
		%Side.position.x = -collision_pos

func _on_animated_sprite_2d_animation_changed():
	%Up.set_deferred("disabled", animated_sprite_2d.animation != "Up")
	%Down.set_deferred("disabled", animated_sprite_2d.animation != "Down")
	%Side.set_deferred("disabled", animated_sprite_2d.animation != "Side")

func _on_detect_up_body_entered(body):
	set_random_direction()

func _on_detect_down_body_entered(body):
	set_random_direction()

func _on_detect_right_body_entered(body):
	set_random_direction()

func _on_detect_left_body_entered(body):
	set_random_direction()

func _on_animated_sprite_2d_animation_looped():
	bite_SFX.play()
	var hole = HOLE.instantiate()
	get_tree().current_scene.add_child(hole)
	hole.global_position = global_position
