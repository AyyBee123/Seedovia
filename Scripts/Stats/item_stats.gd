class_name item_stats extends Node

@export var item_name: String
var category: String # item type (consumable, helmet, gloves, etc)
var rarity: int # 1 = common, 5 = legendary (placeholder values just to show that higher = rarer)
var properties: Array[String] # Store properties as string and read them

func initialize(stats: item_stats):
	item_name = stats.item_name
	category = stats.category
	rarity = stats.rarity
	properties = stats.properties
