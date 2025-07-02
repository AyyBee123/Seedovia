extends Control

@onready var label = %"Victory?"
@onready var background = %Background

var tween

func _ready():
	label.modulate.a = 0
	background.modulate.a = 0
	tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(label, "modulate:a", 1, 1)
	tween.tween_interval(0.5)
	tween.tween_property(background, "modulate:a", 1, 1)
