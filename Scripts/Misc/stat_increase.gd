extends Node2D

@onready var label := %Label
@onready var label_container := %LabelContainer
@onready var ap := %AnimationPlayer

func set_and_animate_stat(value: float, stat: String) -> void:
	label.text = "+" + add_commas(int(round(value))) + "% " + stat
	ap.play("Rise")

func remove():
	ap.stop()
	if is_inside_tree():
		get_parent().remove_child(self)
	queue_free()

func add_commas(value):
	var text = ""
	while value >= 1000:
		text += ",%03d" % (value % 1000)
		value /= 1000
	return str(value) + text
