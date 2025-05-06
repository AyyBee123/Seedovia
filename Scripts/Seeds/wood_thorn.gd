extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
var WOOD_THORN = load("res://Scenes/Seeds/Wood Thorn.tscn")

const SPREAD = PI/6

var _spawn_more_thorns: bool = true

func _ready():
	super._ready()
	if _spawn_more_thorns:
		await get_tree().physics_frame
		var directions = [-SPREAD, SPREAD]
		for dir in directions:
			var thorn = WOOD_THORN.instantiate()
			thorn.shader = shader
			thorn._spawn_more_thorns = false
			thorn.collisions = collisions
			thorn.source = source
			thorn.target_group = target_group
			thorn.desired_direction = desired_direction.rotated(dir)
			thorn.slot_index = slot_index
			thorn.seed_slot_number = seed_slot_number
			thorn.set_next_seed_slot_number = set_next_seed_slot_number
			thorn.set_next_seed_slot_index = set_next_seed_slot_index
			thorn.ignore_first_collision = ignore_first_collision
			thorn.transferred_speed_multiplier *= transferred_speed_multiplier
			thorn.transferred_range_multiplier *= transferred_range_multiplier
			thorn.transferred_size_multiplier *= transferred_size_multiplier
			thorn.transferred_damage_multiplier *= transferred_damage_multiplier
			thorn.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
			thorn.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
			thorn.modulate = modulate
			get_tree().current_scene.add_child.call_deferred(thorn)
			thorn.global_position = global_position
			weapon_fired.emit(thorn)
		
		if get_next_weapon():
			# shoot the next seed alongside the thorns
			var seed_directions = [-SPREAD * 1/2, SPREAD * 1/2]
			for dir in seed_directions:
				weapon_direction = desired_direction.rotated(dir)
				shoot_next_weapon()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.walnut_hit)
	explode()
	queue_free.call_deferred()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.25 * SIZE
	splash.source = self
	splash.modulate = Color("4f2e27")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
