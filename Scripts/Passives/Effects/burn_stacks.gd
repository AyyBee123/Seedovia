extends Node

func _process(delta):
	print(get_child_count())
	if get_child_count() > 0:
		get_parent().modulate = Color.DARK_ORANGE
	else:
		get_parent().modulate = Color.WHITE
		
	if get_child_count() > 10: # max of 10 burn stacks, the oldest stack get removed if over 10
		get_children()[0].queue_free()
