extends Node

@onready var hit = $Hit
@onready var jetstream_hit = $"Jetstream Hit"
@onready var corn_mild_explosion = $"Corn MildExplosion"
@onready var bubble_pop = $BubblePop
@onready var pepper_mild_explosion = $"Pepper MildExplosion"
@onready var strawberry_mild_explosion = $"Strawberry MildExplosion"
@onready var pepper_child_mild_explosion = $"Pepper Child MildExplosion"
@onready var walnut_hit = $"Walnut Hit"
@onready var sunder_explosion = $SunderExplosion
@onready var sentient_pot_bite = $"Sentient Pot Bite"
@onready var maple_splat = $"Maple Splat"
@onready var blessed_dandelion_hit = $"Blessed Dandelion Hit"
@onready var chocolate_splat = $"Chocolate Splat"
@onready var stomp = $Stomp
@onready var bomb_pot_explosion = $"Bomb Pot Explosion"

func _ready():
	SignalBus.play_audio.connect(play)

func play(audio):
	SfxDeconflicter.play(audio)
