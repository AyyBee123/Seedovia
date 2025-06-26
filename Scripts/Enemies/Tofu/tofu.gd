extends "res://Scripts/Enemies/enemy.gd"

@onready var cooldown_time = $"Cooldown Time"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_polygon_2d = $"Enemy Hitbox/CollisionPolygon2D"
@onready var stretch = $Stretch
@onready var whip = $Whip

const SPARKLE = preload("res://Scenes/Misc/Sparkle.tscn")

const X_DISTANCE = 8
const Y_DISTANCE = 10
const SPREAD = PI/2

var tween
var angles: Array
var direction: Vector2
var move_direction: Vector2
var distance: float

func _ready():
	randomize()
	super._ready()
	
	for i in TAU / SPREAD:
		var angle = SPREAD * i - SPREAD / 2
		if angle < 0:
			angle += TAU
		angles.append(angle)

func _physics_process(delta):
	super._physics_process(delta)

func _on_cooldown_time_timeout():
	direction = global_position.direction_to(player.global_position)
	distance = global_position.distance_to(player.global_position)
	var angle = direction.angle()
	# makes the angle rotation go from 0 to 360, instead of 0 to 180 and then -180 to 0
	if angle < 0:
		angle += TAU
	
	if angle >= angles[1] and angle < angles[2]:
		move_direction = Vector2(0, 1)
	elif angle >= angles[2] and angle < angles[3]:
		move_direction = Vector2(-1, 0)
	elif angle >= angles[3] and angle < angles[0]:
		move_direction = Vector2(0, -1)
	else:
		move_direction = Vector2(1, 0)
	
	# size the sprite and collision box should stretch to
	var size = abs(move_direction) * distance * abs(direction) / Vector2(X_DISTANCE, Y_DISTANCE) / 4 \
			+ Vector2(abs(move_direction.y), abs(move_direction.x))
	var dir = move_direction * distance * abs(direction)
	
	# stretch, cardinally, towards the player's current position
	tween = get_tree().create_tween()
	tween.tween_property(animated_sprite_2d, "scale", size/2, 0.75)
	tween.parallel().tween_property(collision_polygon_2d, "scale", size/2, 0.75)
	tween.parallel().tween_callback(func(): stretch.play())
	tween.parallel().tween_property(self, "position", dir/2, 0.75).as_relative().set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.15)
	tween.tween_property(animated_sprite_2d, "scale", Vector2.ONE, 0.1)
	tween.parallel().tween_property(collision_polygon_2d, "scale", Vector2.ONE, 0.1)
	tween.parallel().tween_property(self, "position", dir/2, 0.1).as_relative().set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): 
		for i in 10:
			spawn_sparkle("eeeaca")
	)
	tween.tween_callback(func(): whip.play())
	tween.tween_callback(func(): cooldown_time.start())

func spawn_sparkle(color: Color):
	var sparkle = SPARKLE.instantiate()
	sparkle.scale *= 2
	sparkle.modulate = color
	sparkle.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	add_child(sparkle)
	sparkle.global_position = global_position + sparkle.direction * 40

func _exit_tree():
	if tween:
		tween.kill()
