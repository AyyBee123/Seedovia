extends Node

const RANGE_INCREASE = 0.3
const HOMING_STRENGTH = 5

var player
var source
var new_rot

func _ready():
	player = Targets.get_player()
	source = get_parent().get_parent()
	if source == player:
		player._player_stats.set_stat("Weapon_Range", "+", RANGE_INCREASE)
	if source.is_in_group("Homing") and "ROTATION_SPEED" in source:
		source.ROTATION_SPEED *= 2
	elif source.is_in_group("Weapon") and "direction" in source:
		source.rotation = source.direction.angle()
	source.weapon_fired.connect(transfer_passive)

func _exit_tree():
	if source == player:
		player._player_stats.set_stat("Weapon_Range", "+", -RANGE_INCREASE)

func _physics_process(delta):
	if source == Targets.get_player():
		return
	if source.is_in_group("Homing"):
		return
	elif source.is_in_group("Weapon"):
		if get_nearest_enemy():
			var rotation_angle = source.global_position.direction_to(get_nearest_enemy().global_position)
			source.direction = source.direction.lerp(rotation_angle,HOMING_STRENGTH * delta)

func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	weapon.get_node("Passives").add_child(self.duplicate())

func get_nearest_enemy():
	var enemies = Targets.get_enemy_hitboxes()
	var nearest_enemy = null
	var nearest_distance = null
	for i in enemies.size():
		if nearest_enemy == null:
			if is_instance_valid(enemies[i]): # prevents game from crashing if enemy dies to quickly
				nearest_enemy = enemies[i]
				nearest_distance = enemies[i].global_position.distance_squared_to(source.global_position)
		else:
			if is_instance_valid(enemies[i]):
				if nearest_distance > enemies[i].global_position.distance_squared_to(source.global_position):
					nearest_distance = enemies[i].global_position.distance_squared_to(source.global_position)
					nearest_enemy = enemies[i]
	return nearest_enemy
