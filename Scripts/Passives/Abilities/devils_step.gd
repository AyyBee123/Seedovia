extends Node

var frames: Array
var source
var animated_sprite: String
var pos: Vector2
var weapon_direction: Vector2

func _ready():
	source = get_parent().get_parent()
	
	if source == Targets.get_player():
		animated_sprite = "Player Sprite"
		if source.name == "Opium":
			pass
		elif source.name == "Pizza Man":
			frames = [0, 4]
		else:
			frames = [1, 3]
	elif source.is_in_group("Pizzaria"):
		animated_sprite = "AnimatedSprite2D"
		frames = [0, 4]
	else:
		animated_sprite = "AnimatedSprite2D"
		frames = [1, 3]
	if source.get_node_or_null(animated_sprite):
		source.get_node(animated_sprite).frame_changed.connect(_on_animated_sprite_frame_changed)

func _on_animated_sprite_frame_changed():
	if source.get_node_or_null(animated_sprite):
		if source.get_node(animated_sprite).animation == "Move":
			if source.get_node(animated_sprite).frame in frames:
				step()

func step():
	var weapon = null if PlayerInventory.seeds.get(2) == null else PlayerInventory.seeds.get(2).scene
	if not weapon:
		return
	var weapon_instance = weapon.instantiate()
	weapon_instance.slot_index = 2
	weapon_instance.seed_slot_number = 2
	weapon_instance.previous_weapon = source
	weapon_instance.source = source
	if source.name != "Alp":
		weapon_instance.transferred_size_multiplier *= 0.75
		weapon_instance.transferred_damage_multiplier *= 0.5
		weapon_instance.transferred_blast_radius_multiplier *= 0.75
	if source.get_node_or_null("Shadow"):
		pos = source.get_node("Shadow").global_position
	else:
		pos = source.global_position
	if get_nearest_enemy():
		weapon_instance.desired_direction = pos.direction_to(get_nearest_enemy().global_position)
	else:
		weapon_instance.desired_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	weapon_direction = weapon_instance.desired_direction
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = pos
	source.weapon_fired.emit(weapon_instance)
	if source == Targets.get_player():
		source.seed_fired.emit(weapon_instance)

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var nearest_enemy = null
	var nearest_distance = null
	for i in enemies.size():
		if nearest_enemy == null:
			nearest_enemy = enemies[i]
			nearest_distance = enemies[i].global_position.distance_squared_to(source.global_position)
		else:
			if nearest_distance > enemies[i].global_position.distance_squared_to(source.global_position):
				nearest_distance = enemies[i].global_position.distance_squared_to(source.global_position)
				nearest_enemy = enemies[i]
	return nearest_enemy
