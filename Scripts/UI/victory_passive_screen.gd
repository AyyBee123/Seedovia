extends MarginContainer

const PASSIVE_CONTAINER = preload("res://Scenes/UI/Passive Container.tscn")

func _ready():
	for p in PlayerPassives.passive_list:
		var container = PASSIVE_CONTAINER.instantiate()
		container.get_node("%Image").texture = p.sprite
		container.get_node("%Description").text = p.description
		container.get_node("%Name").text = p.passive_name
		%Passives.add_child(container)
	$ScrollContainer.set_v_scroll(0)
