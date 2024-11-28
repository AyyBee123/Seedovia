extends "res://Scripts/Bosses/boss.gd"

@onready var lunacy_projectile := preload("res://Scenes/Enemies/Weapons/Lunacy Projectile.tscn")
@onready var fire_rate := $"Fire Rate"

var lunacy_proj_pool := []
var teeth_pool := []
var pos_x: float
var pos_y: float
var positions := ["UP", "DOWN", "LEFT", "RIGHT"]
var pos

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	fire_lunacy()

## when the object is "destroyed", add it back to the pool
## also add a couple to the pool on _ready
func add_to_pool(object: Node2D, object_pool: Array) -> void:
	object_pool.append(object)

## pull the object from the pool and use it in the scene (when firing a projectile, for instance)
func pull_from_pool(scene: PackedScene, object_pool: Array) -> Node2D:
	var object: Node2D
	if object_pool.is_empty():
		object = scene.instantiate()
	else:
		object = object_pool[0]
		object_pool.remove_at(0)
	object.source = self
	object.global_position = Vector2(pos_x, pos_y)
	match pos:
		"UP":
			object.direction = Vector2.DOWN
		"DOWN":
			object.direction = Vector2.UP
		"LEFT":
			object.direction = Vector2.RIGHT
		"RIGHT":
			object.direction = Vector2.LEFT
	object.set_process(true)
	object.set_physics_process(true)
	object.show()
	return object

func fire_lunacy():
	if not fire_rate.is_stopped():
		return
	fire_rate.start()
	
	pos = positions.pick_random()
	match pos:
		"UP":
			pos_x = randi_range(-6, 5) * 128 + 64
			pos_y = -640
		"DOWN":
			pos_x = randi_range(-6, 5) * 128 + 64
			pos_y = 640
		"LEFT":
			pos_x = -1050
			pos_y = randi_range(-3, 2) * 128 + 64
		"RIGHT":
			pos_x = 1050
			pos_y = randi_range(-3, 2) * 128 + 64
	
	var proj = pull_from_pool(lunacy_projectile, lunacy_proj_pool)
	if not proj.get_parent(): # if it's not already added as a child
		get_tree().current_scene.add_child(proj)
