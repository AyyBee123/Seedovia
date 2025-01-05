extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader = $ResourcePreloader

var source
var source_passives
var chained_enemies
var collided_object
var pos

func _ready():
	source = get_parent().get_parent()
	source_passives = source.get_node("Passives").get_children()
	chance = 0.5 if source.has_method("chain_lightning") else 1 # 100% chain chance from weapons, 50% from lightning
	source.has_collided.connect(collide)
	source.weapon_fired.connect(transfer_passive)
	super._ready()

func collide(object):
	collided_object = object
	pos = source.pos if source.has_method("chain_lightning") else source.global_position
	chance_to_trigger(source)

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	# make a new banana mine passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(self.duplicate())
	source_passives = source.get_node("Passives").get_children()

func trigger(weapon = null):
	if chained_enemies == null:
		chained_enemies = Targets.get_enemy_hitboxes()
	var lightning = resource_preloader.get_resource("Lightning").instantiate()
	for passive in source_passives:
		lightning.get_node("Passives").add_child(passive.duplicate())
	var nearest_enemy = get_nearest_enemy(collided_object)
	if nearest_enemy != null:
		lightning.region_rect = Rect2(0, 0, pos.distance_to(nearest_enemy.global_position), 17)
		if not weapon.has_method("chain_lightning"):
			lightning.nearest_enemy = nearest_enemy
		else:
			lightning.nearest_enemy = get_random_enemy(collided_object)
		if source.damage_multiplier:
			lightning.damage = player._player_stats.get_stat("Weapon_Damage") * source.damage_multiplier / 2
			lightning.damage_multiplier = source.damage_multiplier
		get_tree().current_scene.add_child.call_deferred(lightning)
		lightning.global_position = pos
		lightning.pos = nearest_enemy.global_position
		lightning.look_at(nearest_enemy.global_position)
	elif nearest_enemy == null and not weapon.has_method("chain_lightning"):
		lightning.region_rect = Rect2(0, 0, randf_range(50, 150), 17)
		if source.damage_multiplier:
			lightning.damage = player._player_stats.get_stat("Weapon_Damage") * source.damage_multiplier / 2
			lightning.damage_multiplier = source.damage_multiplier
		get_tree().current_scene.add_child.call_deferred(lightning)
		lightning.global_position = pos
		lightning.rotation = randf_range(0, TAU)

func get_nearest_enemy(object):
	if object != null and object.is_in_group("Enemies"):
		# removes the hit enemy from the array so that the projectile does not target it when "bouncing"
		for i in range(chained_enemies.size()):
			if chained_enemies[i] == object:
				chained_enemies.remove_at(i)
				break # break out of the loop because only one enemy is hit anyway, so it's reduntent to continue
	var nearest_enemy = null
	var nearest_distance = null
	for i in chained_enemies.size():
		if nearest_enemy == null:
			if is_instance_valid(chained_enemies[i]): # prevents game from crashing if enemy dies to quickly
				nearest_enemy = chained_enemies[i]
				nearest_distance = chained_enemies[i].global_position.distance_squared_to(pos)
		else:
			if is_instance_valid(chained_enemies[i]):
				if nearest_distance > chained_enemies[i].global_position.distance_squared_to(pos):
					nearest_distance = chained_enemies[i].global_position.distance_squared_to(pos)
					nearest_enemy = chained_enemies[i]
	return nearest_enemy

func get_random_enemy(object):
	if not object.is_in_group("Enemies") or object == null:
		return Targets.get_enemy_hitboxes().pick_random()
	var enemy = Targets.get_enemy_hitboxes().pick_random()
	while enemy == collided_object:
		enemy = Targets.get_enemy_hitboxes().pick_random()
	return enemy

func chain_lightning():
	pass
