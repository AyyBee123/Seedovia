extends "res://Scripts/Seeds/seed_template.gd"

var enemies_in_area: Array
var tick_timers: Array
var tick_rate := 0.2
var size
var tween

func _ready():
	super._ready()
	size = scale
	randomize()
	scale = Vector2.ZERO
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", size, 0.1)

func _physics_process(delta):
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				if enemies_in_area[i] == player:
					enemies_in_area[i]._player_stats.take_damage(1)
					tick_timers[i].start(tick_rate)
					return
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start(tick_rate)

func travelled_distance():
	pass

func _on_hitbox_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hitbox_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		if is_instance_valid(body):
			enemies_in_area.append(body)
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate / FIRE_RATE
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		if is_instance_valid(body):
			var index = enemies_in_area.find(body)
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func _on_lifetime_timeout():
	$AnimationPlayer.play("new_animation")

func destroy():
	if tween:
		tween.kill()
	queue_free.call_deferred()
