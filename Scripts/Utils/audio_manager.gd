extends Node

@onready var hit = $Hit
@onready var jetstream_hit = $"Jetstream Hit"
@onready var corn_mild_explosion = $"Corn MildExplosion"
@onready var bubble_pop = $BubblePop
@onready var pepper_mild_explosion = $"Pepper MildExplosion"
@onready var strawberry_mild_explosion = $"Strawberry MildExplosion"
@onready var pepper_child_mild_explosion = $"Pepper Child MildExplosion"
@onready var walnut_hit = $"Walnut Hit"
@onready var sunder_explosion = $SunderExplosion
@onready var sentient_pot_bite = $"Sentient Pot Bite"
@onready var maple_splat = $"Maple Splat"
@onready var blessed_dandelion_hit = $"Blessed Dandelion Hit"
@onready var chocolate_splat = $"Chocolate Splat"
@onready var stomp = $Stomp
@onready var bomb_pot_explosion = $"Bomb Pot Explosion"
@onready var bubble_pop_2 = $BubblePop2
@onready var pome_mild_explosion = $"Pome MildExplosion"
@onready var pome_mild_explosion_2 = $"Pome MildExplosion2"
@onready var pome_mild_explosion_3 = $"Pome MildExplosion3"
@onready var crunch = $Crunch
@onready var hit_2 = $Hit2
@onready var spore_pop = $SporePop
@onready var sparkle = $Sparkle
@onready var sparkle_higher_pitch = $Sparkle_higher_pitch
@onready var sparkle_lower_vol = $Sparkle_lower_vol
@onready var fools_gold = $"Fools Gold"
@onready var rock_2 = $Rock2
@onready var rock = $Rock
@onready var fart = $Fart
@onready var crit = $Crit
@onready var ding_2 = $Ding2
@onready var impact_high_pitch = $"Impact High Pitch"
@onready var fire_explosion = $"Fire Explosion"
@onready var hit_3 = $Hit3
@onready var place_item = $PlaceItem
@onready var inventory_select = $InventorySelect
@onready var ui_button = $UIButton
@onready var popup = $Popup
@onready var popup_close = $PopupClose
@onready var popup_2 = $Popup2
@onready var popup_close_2 = $PopupClose2
@onready var pickup = $Pickup
@onready var drop = $Drop
@onready var use = $Use
@onready var use_2 = $Use2
@onready var coin = $Coin
@onready var player_hit = $PlayerHit
@onready var bounce = $Bounce
@onready var quiet_thud = $QuietThud
@onready var dash = $Dash
@onready var death = $Death
@onready var cash = $Cash
@onready var smack = $Smack
@onready var light_impact = $LightImpact
@onready var ping = $Ping
@onready var shock = $Shock
@onready var chip = $Chip
@onready var bite = $Bite
@onready var bite_2 = $Bite2
@onready var bite_3 = $Bite3
@onready var bite_4 = $Bite4
@onready var bite_5 = $Bite5
@onready var bite_6 = $Bite6
@onready var bite_7 = $Bite7
@onready var bite_8 = $Bite8
@onready var crunch_2 = $Crunch2
@onready var mushroom_boing = $"Mushroom Boing"
@onready var mushroom_boing_2 = $"Mushroom Boing2"
@onready var sausage = $Sausage

func _ready():
	SignalBus.play_audio.connect(play)

func play(audio):
	SfxDeconflicter.play(audio)
