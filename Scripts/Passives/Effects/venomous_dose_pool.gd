extends Sprite2D

var DAMAGE: float = 4
var enemies_in_area: Array
var tick_timers: Array
var tick_rate := 0.125

func _ready():
	SeedManager.add_projectile(self)

func _physics_process(delta):
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start(tick_rate)
	rotation_degrees += 15 * delta

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

func _on_lifetime_timeout():
	destroy()

func destroy():
	SeedManager.seeds_on_screen.erase(self)
	queue_free.call_deferred()
