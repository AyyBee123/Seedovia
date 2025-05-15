extends Node

@onready var enemy = get_parent()

const BURNING_SPRITE = preload("res://Scenes/Passives/Effects/Burning Sprite.tscn")

# these variables are declared in the burning weapon script
var duration: float
var tick: float
var damage: float
var current_tick: float

var burning_sprite

func _ready():
	duration += 0.001 # this is to trigger the fire tick one more time right before it goes away
	current_tick = tick

func _process(delta):
	if not enemy.get_node_or_null("Burning Sprite"):
		burning_sprite = BURNING_SPRITE.instantiate()
		enemy.add_child(burning_sprite)
	
	current_tick -= delta
	duration -= delta
	
	if current_tick <= 0:
		enemy._enemy_stats.take_damage(damage)
		current_tick = tick
		
	if duration <= 0:
		if burning_sprite:
			burning_sprite.queue_free()
		queue_free()
