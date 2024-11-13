class_name character_class extends Resource

@export var character_name: String # Character's name
@export var sprite: Texture # Sprite of the character
@export var hand_sprite: Texture # Sprite of the character's hand
@export var move_animation: Array[Texture] # List of textures to make movement the animation
@export var starting_inventory: Array[Resource] # Inventory the character starts with
@export var starting_talismans: Array[Resource] # Talismans the character starts with
@export var starting_seeds: Array[Resource] # Seeds the character starts with
@export var starting_passives: Array[PackedScene] # Passives the character starts with
