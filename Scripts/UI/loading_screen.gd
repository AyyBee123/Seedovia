extends Control

@onready var walnut = %Walnut

func _ready():
	pass

func _process(delta):
	var progress = []
	walnut.rotation += PI * delta
