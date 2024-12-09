class_name item_class extends Resource

@export var item_name: String
@export var texture: Texture
@export_multiline var description: String
@export var unlocked: bool = true
	
func get_item_name() -> String:
	return item_name
	
func get_texture() -> Texture:
	return texture
