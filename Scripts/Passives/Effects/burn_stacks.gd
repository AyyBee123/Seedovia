extends Node

var burn
var max_stacks := 10

func _process(delta):
	if get_child_count() > 0:
		get_parent().get_node("AnimatedSprite2D").self_modulate = Color.DARK_ORANGE
	else:
		get_parent().get_node("AnimatedSprite2D").self_modulate = Color.WHITE
	# max of <max stacks> burn stacks, the oldest burn effect gets removed if over max stacks
	if get_child_count() > max_stacks:
		get_children()[0].queue_free()
