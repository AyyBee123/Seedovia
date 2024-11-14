extends Line2D

var MAX_LENGTH: int = 250
var points_queue: Array

func _physics_process(delta):
	# enqueue point to the current position
	var pos: Vector2 = get_parent().global_position
	points_queue.push_back(pos)
	
	# dequeue points if there are too many
	if points_queue.size() > MAX_LENGTH:
		points_queue.pop_front()
	
	# clear old line2D point array
	clear_points()
	
	# insert points from the queue to the line2D points array
	for point in points_queue:
		add_point(get_parent().to_local(point))
