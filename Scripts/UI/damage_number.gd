extends Node

@onready var label := %Label
@onready var label_container := %LabelContainer
@onready var ap := %AnimationPlayer
	
func remove():
	ap.stop()
	if is_inside_tree():
		get_parent().remove_child(self)
	queue_free()
	
func set_and_animate_damage(value: float, start_pos: Vector2, height: float, spread: float) -> void:
	label.text = str(value)
	ap.play("Rise and Fall")
	
	var tween = get_tree().create_tween()
	var end_pos = Vector2(randf_range(-spread, spread), -height)
	var tween_length = ap.get_animation("Rise and Fall").length
	
	tween.tween_property(label_container, "position", end_pos, tween_length)
