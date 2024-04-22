extends Control

var item_name
var type
var description
var rarity

func _ready():
	$Background/Name.text = item_name
	$Background/Type.text = type
	$Background/Description.text = description
	match rarity:
		0: # Common
			set_values(Color.DARK_GRAY, "Common")
		1: # Uncommon
			set_values(Color.DODGER_BLUE, "Uncommon")
		2: # Rare
			set_values(Color.PALE_GOLDENROD, "Rare")
		3: # Epic
			set_values(Color.BLUE_VIOLET, "Epic")
		4: # Legendary
			set_values(Color.DARK_ORANGE, "Legendary")
		5: # Unique
			set_values(Color.CRIMSON, "Unique")
		-1: # N/A
			set_values(Color.WHITE, "")

func set_values(color: Color, text: String):
	$Background/Rarity.self_modulate = color
	$Background/Rarity.text = "[right]" + text
	$Background.self_modulate = color
	$Background/Name.self_modulate = color
