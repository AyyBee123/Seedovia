class_name SaveGame extends Resource

const SAVE_GAME_PATH := "user://Save Game/save.tres"

# use this to detect old player saves and update the data
@export var version := 1

@export var character: Resource
@export var inventory: Resource

@export var global_position := Vector2.ZERO

func write_save() -> void:
	ResourceSaver.save(self, SAVE_GAME_PATH)
	
static func save_exists() -> bool:
	return ResourceLoader.exists(SAVE_GAME_PATH)
	
static func load_save() -> Resource:
	if not ResourceLoader.has_cached(SAVE_GAME_PATH):
		return ResourceLoader.load(SAVE_GAME_PATH, "", 1)
	return
