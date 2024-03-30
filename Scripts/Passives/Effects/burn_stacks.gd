extends Node

var debuff_ui = preload("res://Scenes/UI/debuff_ui.tscn")
var image = preload("res://Sprites/Debuff Icons/Burn.png")
@onready var debuffs_ui := $"../Debuffs UI"

var burn
var max_stacks := 10

var has_debuff := false

func _ready():
	burn = debuff_ui.instantiate()
	burn.get_node("Sprite").texture = image

func _process(delta):
	burn.get_node("Amount").text = str(get_child_count())
	if get_child_count() > 0:
		get_parent().self_modulate = Color.DARK_ORANGE
		if not has_debuff:
			debuffs_ui.add_child(burn)
			has_debuff = true
	else:
		get_parent().self_modulate = Color.WHITE
		if has_debuff:
			debuffs_ui.remove_child(burn)
			has_debuff = false
	
	if get_child_count() > max_stacks: # max of <max stacks> burn stacks, the oldest stack get removed if over max stacks
		get_children()[0].queue_free()
