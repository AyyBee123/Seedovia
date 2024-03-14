extends TextureProgressBar

@onready var damage_bar := $"Enemy Health"
@onready var delay := $"White Bar Delay"
var rate: float = 0.08

var health: float = 0 : set = set_health

func set_health(new_health):
	var previous_health = health
	health = min(damage_bar.max_value, new_health)
	damage_bar.value = health
	
	if health <= 0: # if entity dies
		queue_free()
	
	if health < previous_health: # if entity takes damage
		delay.start()
	else: #healing
		value = health


func init_health(_health):
	health = _health
	damage_bar.max_value = health
	damage_bar.value = health
	max_value = health
	value = health


func _on_white_bar_delay_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "value", health, rate).set_ease(1)
