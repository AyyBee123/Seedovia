extends CharacterBody2D

signal weapon_fired(weapon)

@onready var hand = $"Rotation Point/Hand"
@onready var rotation_point = $"Rotation Point"
@onready var sprite = $Sprite2D

var player
var offset
var DAMAGE = 10
var SIZE = 1
var BLAST_RADIUS = 1
var damage_multi

func _ready():
	player = Targets.get_player()
	if player.name == "Salvia":
		damage_multi = 0.5
	else:
		damage_multi = 0.2
	player.weapon_fired.connect(shoot)

func _physics_process(delta):
	var frameIndex: int = player.find_child("Player Sprite").get_frame()
	var animationName: String = player.find_child("Player Sprite").animation
	var spriteFrames: SpriteFrames = player.find_child("Player Sprite").get_sprite_frames()
	var currentTexture: Texture2D = spriteFrames.get_frame_texture(animationName, frameIndex)

	scale = player.scale
	sprite.flip_h = player.find_child("Player Sprite").flip_h
	sprite.texture = currentTexture
	sprite.position = player.find_child("Player Sprite").position
	hand.texture = player.find_child("Hand").texture
	rotation_point.rotation = player.find_child("Rotation Point").rotation
	
	global_position = player.global_position + offset

func shoot(seed):
	var weapon_instance = null if PlayerInventory.seeds.size() == 0 else PlayerSeeds.load_weapons()[0].instantiate()
	weapon_instance.initial_weapon = true
	weapon_instance.slot_index = 0
	weapon_instance.previous_weapon = self
	weapon_instance.seed_slot_number = PlayerSeeds.seed_indices[0]
	weapon_instance.desired_direction = Vector2.RIGHT.rotated(rotation_point.rotation)
	weapon_instance.transferred_damage_multiplier *= damage_multi
	weapon_instance.transferred_size_multiplier *= 0.75
	weapon_instance.modulate.a = 155.0 / 255.0
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = hand.global_position
	weapon_fired.emit(weapon_instance)
