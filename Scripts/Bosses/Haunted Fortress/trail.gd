class_name trail extends Line2D

const MAX_POINTS: int = 2000
@onready var curve := Curve2D.new()
@onready var lifetime = $Lifetime

func _process(delta):
	curve.add_point(get_parent().global_position) # add point to the parent's position to create a trail
	if curve.get_baked_points().size() > MAX_POINTS: # if the number of points exceeds the max
		curve.remove_point(0) # remove oldest point
	points = curve.get_baked_points() # gets all the created points, listed as an array of Vector2Ds
	if lifetime.is_stopped(): # remove point after their lifetime timer expires
		queue_free()

func stop():
	set_process(false)
	queue_free()

static func create() -> trail:
	var scn = preload("res://Scenes/Misc/Trail.tscn")
	return scn.instantiate()
