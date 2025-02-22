extends Sprite2D

@onready var aura_tick_rate = $"Aura Tick Rate"

var enemies_in_area: Array
var tick_timers: Array
var damage_multiplier
var radius: float = scale.x
var radius_multiplier
var weapon

var DAMAGE: float
var BLAST_RADIUS: float
var FIRE_RATE: float
var RANGE: float
var SIZE: float
var SPEED: float

func _physics_process(delta):
	scale = Vector2.ONE * radius * radius_multiplier
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE * damage_multiplier)
				tick_timers[i].start()

func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = aura_tick_rate.wait_time
			timer.one_shot = true
			tick_timers.append(timer)

func _on_area_2d_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)
