extends Sprite2D

@onready var marker = $Marker2D

const FOLLOW_SPEED = 15

var source
var pos

func _physics_process(delta):
	if not is_instance_valid(source):
		queue_free()
		return
	
	global_position = global_position.lerp(pos.global_position, delta * FOLLOW_SPEED)
