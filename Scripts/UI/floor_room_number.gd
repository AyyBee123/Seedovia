extends Control

func _ready():
	$Text.text = "[right]Room: " + str(LevelList.floor_number + 1) + "-" + str(LevelList.room_number)
