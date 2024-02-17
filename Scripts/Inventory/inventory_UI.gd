extends Control

@onready var inv: inventory = preload("res://Scenes/Inventory/inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	inv.update.connect(update_slots)
	update_slots()
	self.visible = false
	
func update_slots():
	for i in range(min(inv.items.size(), slots.size())):
		slots[i].update(inv.items[i])
	
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		# toggle inventory open/close
		self.visible = !self.visible
