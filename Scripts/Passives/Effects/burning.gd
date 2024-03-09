extends Node

@onready var enemy = get_parent().get_parent()

# these variables are declared in the burning weapon script
var duration: float
var tick: float
var damage: float

var current_tick: float

func _ready():
	duration += 0.001 # this is to trigger the fire tick one more time right before it goes away
	current_tick = tick

func _process(delta):
	current_tick -= delta
	duration -= delta
	
	if current_tick <= 0:
		enemy._enemy_stats.take_damage(damage)
		current_tick = tick
		
	if duration <= 0:
		queue_free()
