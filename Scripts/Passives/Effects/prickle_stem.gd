extends Sprite2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D

var target
var source
var size
var tick_rate
var enemies_in_area: Array
var tick_timers: Array

var DAMAGE: float
var BLAST_RADIUS: float
var FIRE_RATE: float
var RANGE: float
var SIZE: float
var SPEED: float

func _ready():
	visible = false # avoids first frame "flickering"

func _physics_process(delta):
	# check if the source weapon still exists and update the start point position to be at the source's position
	if is_instance_valid(source):
		global_position = source.global_position
		visible = true
	
	# check if the target weapon still exists and update the end point position to the target's position
	if is_instance_valid(target):
		region_rect = Rect2(0, 0, global_position.distance_to(target.global_position), 8)
		look_at(target.global_position)
		collision_shape_2d.shape.size.x = global_position.distance_to(target.global_position)
		collision_shape_2d.position.x = collision_shape_2d.shape.size.x / 2
	
	if not is_instance_valid(target): # if the target is destroyed or removed...
		queue_free()
	
	if not is_instance_valid(source): # if the source is destroyed or removed...
		queue_free()
	
	# damage all enemies that are in the prickle area
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start()

func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate
			timer.one_shot = true
			tick_timers.append(timer)

func _on_area_2d_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)
