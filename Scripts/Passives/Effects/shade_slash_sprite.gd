extends Sprite2D

@onready var trail = $Trail

var sprite

func _ready():
	sprite = get_parent().get_node("Player Sprite")
	scale = sprite.scale
	offset = sprite.offset
	position = sprite.position
	
	trail.offset = sprite.offset + sprite.position
