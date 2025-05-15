extends Sprite2D

var sprite

func _ready():
	sprite = get_parent().get_node("AnimatedSprite2D")

func _process(delta):
	var frameIndex: int = sprite.get_frame()
	var animationName: String = sprite.animation
	var spriteFrames: SpriteFrames = sprite.get_sprite_frames()
	var currentTexture: Texture2D = spriteFrames.get_frame_texture(animationName, frameIndex)
	
	texture = currentTexture
	scale = sprite.scale
	offset = sprite.offset
	position = sprite.position
	flip_h = sprite.flip_h
	flip_v = sprite.flip_v
