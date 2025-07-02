extends MarginContainer

const SEED_CONTAINER = preload("res://Scenes/UI/Seed Container.tscn")

func _ready():
	await get_tree().physics_frame
	for i in PlayerInventory.NUM_SEED_SLOTS:
		var container = SEED_CONTAINER.instantiate()
		if PlayerInventory.seeds.has(i):
			container.get_node("%Image").texture = PlayerInventory.seeds[i].texture
		%Seeds.add_child(container)
	$ScrollContainer.set_v_scroll(0)
