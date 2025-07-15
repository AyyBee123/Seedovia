extends Sprite2D

const SELL_VALUE = preload("res://Scenes/UI/Sell Value.tscn")

const SELL_VALUE_MULTIPLIER = 0.25

var player

func _ready():
	player = Targets.get_player()

func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("Item") or area.get_parent().is_in_group("Pickup Item"):
		sell_item(area.get_parent())

func sell_item(item):
	player = Targets.get_player() # just in case
	var price: int
	match item.item.category:
		"CONSUMABLE":
			price = item.item.shop_price
		"TALISMAN":
			price = GlobalValues.talisman_prices[item.item.rarity]
		"SEED":
			price = GlobalValues.seed_prices[item.item.rarity]
		"PICKUP":
			price = item.item.shop_price
	player._player_stats.set_coins(price * SELL_VALUE_MULTIPLIER)
	item.queue_free()
	Game.audio_manager.play(Game.audio_manager.cash)
	var sell = SELL_VALUE.instantiate()
	get_tree().current_scene.add_child(sell)
	sell.global_position = player.global_position
	sell.set_and_animate_price(price * SELL_VALUE_MULTIPLIER)
	SignalBus.item_sold.emit(price * SELL_VALUE_MULTIPLIER)
	
	for i in 8:
		player.spawn_sparkle(Color("edb800"))
