extends Node

@onready var music = $Music

const GARDEN_THEME = preload("res://Audio/Music/Garden Theme.ogg")
const HALL_THEME = preload("res://Audio/Music/Hall Theme.ogg")
const KITCHEN_THEME = preload("res://Audio/Music/Kitchen Theme.ogg")
const LIBRARY_THEME = preload("res://Audio/Music/Library Theme.ogg")

func play(soundtrack):
	# do nothing if the same soundtrack is already being played
	if music.stream == soundtrack:
		return
	
	music.playing = false
	music.stream = soundtrack
	music.play()

func stop():
	music.stop()
