extends Node

var debuff_ui = preload("res://Scenes/UI/debuff_ui.tscn")
var image = preload("res://Sprites/Debuff Icons/Burn.png")
@onready var debuffs_ui := $"../Debuffs UI"

var burn

var has_debuff := false

func _ready():
	burn = debuff_ui.instantiate()
	burn.get_node("Sprite").texture = image

func _process(delta):
	burn.get_node("Amount").text = str(get_child_count())
	if get_child_count() > 0:
		get_parent().modulate = Color.DARK_ORANGE
		if not has_debuff:
			debuffs_ui.add_child(burn)
			has_debuff = true
	else:
		get_parent().modulate = Color.WHITE
		if has_debuff:
			debuffs_ui.remove_child(burn)
			has_debuff = false
	
	if get_child_count() > 10: # max of 10 burn stacks, the oldest stack get removed if over 10
		get_children()[0].queue_free()
