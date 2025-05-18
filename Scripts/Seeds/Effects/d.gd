extends "res://Scripts/Seeds/s.gd"

const FULL_WORD_CHANCE = 0.02

func _ready():
	randomize()
	super._ready()

func _on_fire_delay_timeout():
	if randf() < FULL_WORD_CHANCE:
		super._on_fire_delay_timeout()
