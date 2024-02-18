extends Node2D

@onready var slots = $"Equipment Slots".get_children()

func _ready():
	for i in range(slots.size()):
		#slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		slots[i].slot_index = i
	inititialize_equipment()
	
func inititialize_equipment():
	for i in range(slots.size()):
		if PlayerInventory.equipment.has(i):
			slots[i].initialize_item(PlayerInventory.equipment[i])

