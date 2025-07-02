extends MarginContainer

const SEED_CONTAINER = preload("res://Scenes/UI/Seed Container.tscn")

func _ready():
	await get_tree().physics_frame
	for i in PlayerInventory.NUM_TALISMAN_SLOTS:
		var container = SEED_CONTAINER.instantiate()
		if PlayerInventory.talismans.has(i):
			container.get_node("%Image").texture = PlayerInventory.talismans[i].texture
		%Talismans.add_child(container)
	$ScrollContainer.set_v_scroll(0)
