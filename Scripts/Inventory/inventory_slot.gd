extends Panel

var item_class = preload("res://Scenes/Inventory/Items/apple.tscn")
var item = null

func _ready():
	if randi() % 2 == 0:
		item = item_class.instantiate()
		$CenterContainer/Panel.add_child(item)
