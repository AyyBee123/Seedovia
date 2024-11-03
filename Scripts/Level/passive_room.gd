extends "res://Scripts/Level/Level.gd"

func _ready():
	super._ready()
	if not LevelList.picked_up_passive:
		var passive_item = resource_preloader.get_resource("Passive Item").instantiate()
		add_child(passive_item)
		passive_item.global_position = Vector2.ZERO
