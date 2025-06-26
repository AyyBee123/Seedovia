extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hand = $"Rotation Point"
@onready var laser_with_reverb = $LaserWithReverb

const SPARKLE = preload("res://Scenes/Misc/Sparkle.tscn")

var positions: Array
var start: bool
var direction: Vector2

func _ready():
	randomize()
	super._ready()
	global_position = Vector2(0, 330)

func _physics_process(delta):
	super._physics_process(delta)
	
	if player:
		positions.append(player.global_position)
	
	if start and positions.size() > 0:
		if global_position.is_equal_approx(positions[0]):
			animated_sprite_2d.play("Idle")
		else:
			hand.rotation = direction.angle()
			animated_sprite_2d.play("Move")
		
		direction = global_position.direction_to(positions[0])
		global_position = positions.pop_front()
	
	animated_sprite_2d.flip_h = direction.x < 0

func _on_delay_timeout():
	animated_sprite_2d.play("Idle")
	start = true
	laser_with_reverb.play()
	for i in 8:
		spawn_sparkle(Color.BLACK)

func spawn_sparkle(color: Color):
	var sparkle = SPARKLE.instantiate()
	sparkle.scale *= 2
	sparkle.modulate = color
	sparkle.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	add_child(sparkle)
	sparkle.global_position = global_position + sparkle.direction * 40
