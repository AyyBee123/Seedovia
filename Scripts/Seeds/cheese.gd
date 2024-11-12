extends "res://Scripts/Seeds/seed_template.gd"

@onready var beginning = $"Cheese Beginning"
@onready var middle = $"Cheese Middle"
@onready var end = $"Cheese End"
@onready var animation_player = $AnimationPlayer
@onready var marker_2d = $"Cheese End/Marker2D"
@onready var collision_shape_2d = %CollisionShape2D

var t = 0.0
var rect_width = 0.0

func _ready():
	super._ready()
	set_variable_sizes()
	rotation = desired_direction.angle()

func _physics_process(delta):
	t += delta * 2.5 # the rate at which the block extends
	rect_width = min(_player_stats.get_stat("Weapon_Range") * range_multiplier * t, \
			_player_stats.get_stat("Weapon_Range") * range_multiplier)
	set_variable_sizes()

func set_variable_sizes():
	middle.region_rect = Rect2(0, 0, rect_width, middle.get_region_rect().size.y)
	# NOTE: the beginning texture is divided by 2 because the collision shape is bigger than expected, for some reason
	collision_shape_2d.shape.size.x = beginning.texture.get_width() / 2 + middle.get_region_rect().size.x \
			+ end.texture.get_width()
	collision_shape_2d.position.x = collision_shape_2d.shape.size.x / 2
	end.position.x = end.texture.get_width() / 2 + middle.get_region_rect().size.x

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
