extends Sprite2D

var DAMAGE: float = 2
var enemies_in_area: Array
var tick_timers: Array
var tick_rate := 0.2

func _physics_process(delta):
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start(tick_rate)

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
	$Area2D/CollisionShape2D.disabled = true
	var tween = get_tree().create_tween()
	tween.tween_callback(func(): remove_from_group("Liquid"))
	tween.tween_property(self, "modulate", Color(modulate.r, modulate.g, modulate.b, 0), 1)
	tween.parallel().tween_property(self, "scale", Vector2.ONE * 0.5, 1)
	tween.tween_callback(queue_free)
