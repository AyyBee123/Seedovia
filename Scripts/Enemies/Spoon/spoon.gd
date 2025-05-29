extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var enemy_hitbox = $"Enemy Hitbox"
@onready var _state_machine = $state_machine
@onready var launch_pos = $"Enemy Hitbox/CollisionPolygon2D"
@onready var pop_SFX = $BubblePop2
@onready var hit_SFX = $Hit2

const LIQUID_BALL = preload("res://Scenes/Enemies/Weapons/Liquid Ball.tscn")

const SCOOP_POS = Vector2(-4, 15) # position of collision box when in the "scoop" animation
const NUMBER_OF_BALLS: int = 6

var LIQUID_TYPE = PackedScene.new()
var liquids_on_screen: Array
var current_liquid = null
var ready_to_scoop: bool

func _ready():
	randomize()
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	
	liquids_on_screen = get_tree().get_nodes_in_group("Liquid")
	liquids_on_screen = liquids_on_screen.filter(func(value): return not value.is_in_group("Used Liquid"))
	if liquids_on_screen.size() > 0 and not is_instance_valid(current_liquid):
		current_liquid = liquids_on_screen.pick_random()
	
	$AnimatedSprite2D.flip_h = velocity.x > 0
	$"Enemy Hitbox".scale.x = -sign(velocity.x) if abs(velocity.x) > 0 else 1

func idle():
	enemy_hitbox.position = Vector2.ZERO
	
	if current_liquid:
		if ready_to_scoop:
			velocity = Vector2.ZERO
		else:
			velocity = _enemy_stats.speed * $Shadow.global_position.direction_to(current_liquid.global_position) \
					.normalized()
		
		if ($Shadow.global_position - current_liquid.global_position).length() <= 28:
			ready_to_scoop = true

func scoop():
	velocity = Vector2.ZERO
	enemy_hitbox.position = SCOOP_POS

func set_liquid():
	if current_liquid:
		current_liquid.add_to_group("Used Liquid")
		LIQUID_TYPE.pack(current_liquid)

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.animation == "Scoop":
		if animated_sprite_2d.frame == 10:
			
			pop_SFX.play()
			
			if is_instance_valid(current_liquid):
				hit_SFX.play()
				
				var texture = current_liquid.texture
				var image = texture.get_image()
				var data = image.get_data()
				var pixel = image.get_pixel(texture.get_width() / 2, texture.get_width() / 2)
				
				for i in NUMBER_OF_BALLS:
					var ball = LIQUID_BALL.instantiate()
					ball.damage = 0
					ball.range = 999999
					ball.speed = randf_range(100, 450)
					ball.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
					ball.modulate = pixel
					ball.LIQUID = LIQUID_TYPE
					get_tree().current_scene.add_child(ball)
					ball.global_position = launch_pos.global_position
			
			LIQUID_TYPE = PackedScene.new()
			current_liquid = null
