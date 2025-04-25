extends "res://Scripts/Level/Level.gd"

func _ready():
	if not LevelList.entered_room:
		var passive_item = resource_preloader.get_resource("Pickup Item").instantiate()
		passive_item.set_item(ResourceLoader.load("res://Resources/Items/Pickups/passive.tres"))
		add_child(passive_item)
		passive_item.global_position = Vector2.ZERO
	super._ready()
	ItemCheck.check_for_pickup_items()
	Global.save_run_room()
