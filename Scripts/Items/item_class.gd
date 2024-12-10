class_name item_class extends Resource

@export var item_name: String
@export var texture: Texture
@export_multiline var description: String
@export var unlocked: bool = true # determines if the item is unlocked by default or if it needs to be unlocked
	
func get_item_name() -> String:
	return item_name
	
func get_texture() -> Texture:
	return texture
