extends "res://Scripts/Seeds/seed_template.gd"

func _ready():
	super._ready()
	visible = false # to remove jittering when the seed spawns

func initialize_position():
	if not position_initialized:
		# spawn the poop behind the player or previous seed
		global_position += Vector2(-desired_direction.x, desired_direction.y).normalized() * 10
		visible = true
		starting_position = global_position
		direction = -desired_direction.normalized()
		position_initialized = true
