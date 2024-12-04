extends Node

var random_seed
var random_talisman

func _ready():
	random_seed = Pool.get_item(Pool.white_shrub_seed_pool)
	PlayerInventory.seeds[0] = random_seed
	random_talisman = Pool.get_item(Pool.white_shrub_talisman_pool)
	PlayerInventory.talismans[0] = random_talisman
	random_talisman.add_stats = true
	get_parent().remove_child(self)
	queue_free.call_deferred()
