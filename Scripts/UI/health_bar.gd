extends TextureProgressBar

## The boss' name is determined by the name of the boss parent node (the CharacterBody2D node)

@onready var damage_bar := $"Enemy Health"
@onready var delay := $"White Bar Delay"
@export var rate: float = 0.08

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
	damage_bar.max_value = _health
	damage_bar.value = _health
	max_value = _health
	value = _health

func _on_white_bar_delay_timeout():
	var tween = get_tree().create_tween()
	# move the white bar to the current (red) health value
	tween.tween_property(self, "value", health, rate).set_ease(1)
