extends "res://Scripts/Seeds/seed_template.gd"

@onready var collision_shape_2d = $Hitbox/CollisionShape2D

var enemies_in_area: Array
var tick_timers: Array
var tween
var original_size

func _ready():
	randomize()
	super._ready()
	starting_position = global_position
	direction = desired_direction.normalized()
	rotation = desired_direction.angle()
	Game.audio_manager.play(Game.audio_manager.light_impact)
	Game.audio_manager.play(Game.audio_manager.light_beam)
	original_size = scale
	scale.y = 0
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale:y", original_size.y, 0.1)
	tween.tween_property(self, "scale:y", 0, 0.25)
	tween.tween_callback(destroy)

func _physics_process(delta):
	super._physics_process(delta)
	
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				if enemies_in_area[i] == player:
					enemies_in_area[i]._player_stats.take_damage(1)
					tick_timers[i].start()
					return
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start()

func travelled_distance():
	pass

func update_position(delta):
	pass

func _collide(body):
	if body.is_in_group("Enemies"):
		if is_instance_valid(body):
			enemies_in_area.append(body.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = 0.1 / FIRE_RATE
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hitbox_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func _exit_tree():
	if tween:
		tween.kill()
