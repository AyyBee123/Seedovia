class_name Achievement extends Node

signal achievement_unlocked
signal achievement_progressed

var progress: float = 0
var completed: bool = false

## Virtual class, must be overwritten.
## Returns the title of the achievement.
func get_title() -> String:
	return "PH_Title"

## Virtual class, must be overwritten.
## Returns the description of the achievement.
func get_description() -> String:
	return "PH_Description"

## Virtual class, must be overwritten.
## Returns the image of the achievement.
func get_image() -> Texture:
	return

## Virtual class, must be overwritten.
## Returns the progress of the achievement.
func get_progress() -> float:
	return -1

## Virtual class, must be overwritten.
## Returns the overall progress goal of the achievement.
func get_progress_goal() -> float:
	return -1

## Must not be overwritten (Use this super function if there are unlocks).
## Sets the current progress of the achievement.
func set_progress(_progress) -> void:
	progress = _progress
	# add unlocks here
