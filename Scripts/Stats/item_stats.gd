class_name item_stats extends Node

@export var item_name: String
@export var stat_modifiers = {} # might change to an array

func initialize(stats: item_stats):
	item_name = stats.item_name
	stat_modifiers = stats.stat_modifiers
