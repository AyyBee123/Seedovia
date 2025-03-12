extends Node

@onready var label := %Label
@onready var label_container := %LabelContainer
@onready var ap := %AnimationPlayer

func remove():
	ap.stop()
	if is_inside_tree():
		get_parent().remove_child(self)
	queue_free()

func set_and_animate_damage(value: float, start_pos: Vector2, height: float, spread: float, \
		color: Color = Color.WHITE, size_multiplier: float = 1) -> void:
	label.text = add_commas(int(round(value)))
	label.modulate = color
	label.scale = size_multiplier * Vector2.ONE
	ap.play("Rise and Fall")
	
	var tween = get_tree().create_tween()
	var end_pos = Vector2(randf_range(-spread, spread), -height)
	var tween_length = ap.get_animation("Rise and Fall").length
	
	tween.tween_property(label_container, "position", end_pos, tween_length)

func add_commas(value):
	var text = ""
	while value >= 1000:
		text += ",%03d" % (value % 1000)
		value /= 1000
	return str(value) + text
