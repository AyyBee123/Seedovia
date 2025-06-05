extends TextureProgressBar

## The boss' name is determined by the name of the boss parent node (the CharacterBody2D node)

@onready var damage_bar := $"Enemy Health"
@onready var delay := $"White Bar Delay"
@export var rate: float = 0.08

var health: float = 0 : set = set_health
var pos

func _ready():
	scale = Vector2.ONE / get_parent().scale * 2 # keep the health bar size consistant across all enemies
	position.x = -size.x / 2 * scale.x # center the health bar
	pos = position

func _process(delta):
	position = pos + get_parent().get_node("AnimatedSprite2D").position
	show_bar()

func show_bar():
	visible = Global.settings.show_damage_numbers # toggle visibility based on the health bar setting

func set_health(new_health):
	var previous_health = health
	health = min(damage_bar.max_value, new_health)
	damage_bar.value = health
	
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
