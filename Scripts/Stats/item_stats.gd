class_name item_stats extends Node

@export var item_name: String
@export var rarity: int # 1 = common, 5 = legendary (placeholder values just to show that higher = rarer)
@export var stat_modifiers = {} # might change to an array

func initialize(stats: item_stats):
	item_name = stats.item_name
	rarity = stats.rarity
	stat_modifiers = stats.stat_modifiers
