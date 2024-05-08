extends Control

var item_name
var type
var description
var rarity
var inventory

func _ready():
	%Name.text = item_name
	%Type.text = type
	%Description.text = description
	set_pos.call_deferred() # defer the call because the modified size of the Box is changed after _ready
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

func set_pos():
	# TODO: make the popups align vertically, while also not causing them to clip off-screen
	global_position.y = Targets.camera.global_position.y

func set_values(color: Color, text: String):
	%Rarity.self_modulate = color
	%"Description Portion".self_modulate = color
	%Bottom.self_modulate = color
	%Rarity.text = "[right]" + text
	%Top.self_modulate = color
	%Name.self_modulate = color
