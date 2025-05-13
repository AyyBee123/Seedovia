extends Control

const OFFSET = 20

var item
var item_name
var type
var description
var detailed_description
var rarity
var inventory
var source # check if the popup was created by the mouse hover or a controller
var slot # check if the popup is from a slot in the inventory (null if not)
static var hue = 0.0
var mystic_color

func _ready():
	%"Hints Portion".visible = slot != null and Global.settings.show_hints
	
	%Name.text = item_name
	%Type.text = type
	%Description.text = ""
	if type == "SEED":
		var stats = {
			"Damage" : item.BASE_DAMAGE, 
			"Fire Rate" : item.BASE_FIRE_RATE, 
			"Range" : item.BASE_RANGE, 
			"Speed" : item.BASE_SPEED
		}
		
		var make_new_line = false
		for text in stats:
			var stat = stats[text]
			if make_new_line:
				%Description.text += "\n"
			make_new_line = false
			if stat != 0:
				%Description.text += text + ":  " + str(stat)
				make_new_line = true
		if description != "" and %Description.text != "":
			%Description.text += "\n"
		%Description.text += description
	else:
		%Description.text = description
	match rarity:
		0: # Common
			set_values(Color.DARK_GRAY, "Common")
		1: # Uncommon
			set_values(Color.LIGHT_SKY_BLUE, "Uncommon")
		2: # Rare
			set_values(Color("ffea81"), "Rare")
		3: # Epic
			set_values(Color.BLUE_VIOLET, "Epic")
		4: # Legendary
			set_values(Color.DARK_ORANGE, "Legendary")
		5: # Unique
			set_values(Color.CRIMSON, "Unique")
		7: # N/A
			set_values(Color.WHITE, "")

func _process(delta):
	if rarity == 6: # Mystic
		mystic_color = Color.from_hsv(hue, 1.0, 1.0, 1.0)
		if hue < 1.0:
			hue += 0.0005
		else:
			hue = 0.0
		set_values(mystic_color, "Mystic")
	set_pos()

func set_pos():
	var inventory_y_pos = inventory.global_position.y
	var inventory_height = inventory.find_child("Inventory Screen").size.y * inventory.scale.y
	# if the popup's position is higher than the inventory screen's
	if global_position.y - %Box.size.y * inventory.scale.y / 2 < inventory_y_pos - OFFSET:
		global_position.y = inventory_y_pos + %Box.size.y * inventory.scale.y / 2 - OFFSET
	# if the popup's position is lower than the inventory screen's
	if global_position.y + %Box.size.y * inventory.scale.y / 2 > inventory_y_pos + inventory_height + OFFSET:
		global_position.y = inventory_y_pos + inventory_height - %Box.size.y * inventory.scale.y / 2 + OFFSET

func set_values(color: Color, text: String):
	material.set("shader_parameter/new_color", color)
	%Rarity.self_modulate = color
	%Rarity.text = "[right]" + text
