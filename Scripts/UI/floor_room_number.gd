extends Control

var floor_name = {
	0: "Garden",
	1: "Hall",
	2: "Kitchen",
	3: "Library",
	4: "Basement",
}

func _ready():
	$Text.text = "[right]" + floor_name[LevelList.floor_number] + ": " \
			+ str(LevelList.floor_number + 1) + "-" + str(LevelList.room_number)
