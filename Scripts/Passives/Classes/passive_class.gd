class_name passive_class extends Resource

var category := "PASSIVE"
@export var passive_name: String
@export var sprite: Texture
@export_multiline var description: String
@export var passive_ability: PackedScene
@export var unlocked: bool = true # determines if the passive is unlocked by default, or if it needs to be unlocked
