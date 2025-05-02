extends Control

@onready var walnut = %Walnut

func _ready():
	Game.music_manager.stop()

func _process(delta):
	var progress = []
	walnut.rotation += PI * delta
