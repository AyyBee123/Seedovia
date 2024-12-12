extends "res://Scripts/Seeds/seed_template.gd"

@onready var animation_player = $AnimationPlayer
@onready var fire_rate = $"Fire Rate"

const CHANCE_TO_SHOOT = 0.08

# these values are declared in the maple.gd script
var damage: float
var size: float
var damage_tick_multiplier := 0.25
var tick_rate := 0.2
var source
var next_weapon
var enemies_in_area := []
var tick_timers := []

func _ready():
	scale = Vector2.ONE * size
	global_position = source.global_position

func _physics_process(delta):
	# damage all enemies that are in the prickle area
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(damage * damage_tick_multiplier)
				tick_timers[i].start()
				has_collided.emit()
	if fire_rate.is_stopped():
		if randf_range(0, 1) <= CHANCE_TO_SHOOT:
			weapon_direction = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
			shoot_next_weapon()
		fire_rate.start()

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
	animation_player.play("new_animation")
