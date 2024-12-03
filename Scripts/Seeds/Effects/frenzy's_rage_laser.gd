extends Sprite2D

@onready var resource_preloader = $ResourcePreloader

var source
var target
var laser_delta := 0.0
var count: int

@onready var space_laser_SFX = $SpaceLaser

func _ready():
	visible = false # avoids first frame "flickering"
	SfxDeconflicter.play(space_laser_SFX)
	count = clamp(1, 1, 3)

func _physics_process(delta):
	laser_delta += delta
	if laser_delta >= 1.0/20.0:
		texture = resource_preloader.get_resource("Frenzy's Rage Laser " + str(count))
		count += 1
		if count >= 3:
			count = 1
		laser_delta = 0.0
	
	# check if the source weapon still exists and update the start point position to be at the source's position
	if is_instance_valid(source):
		global_position = source.get_node("Laser Marker").global_position
		visible = true
	
	# check if the target enemy still exists and update the end point position to the target's position
	if is_instance_valid(target):
		region_rect = Rect2(0, 0, global_position.distance_to(target.global_position), 18)
		look_at(target.global_position)
	
	if not is_instance_valid(target): # if the target is destroyed or removed...
		queue_free()
	
	if not is_instance_valid(source): # if the source is destroyed or removed...
		queue_free()
