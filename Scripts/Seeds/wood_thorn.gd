extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const WOOD_THORN = preload("res://Scenes/Seeds/Wood Thorn.tscn")

const SPREAD = PI/6

var _spawn_more_thorns: bool = true

func _ready():
	super._ready()
	if _spawn_more_thorns:
		await get_tree().physics_frame
		var directions = [-SPREAD, SPREAD]
		for dir in directions:
			var thorn = WOOD_THORN.instantiate()
			thorn._spawn_more_thorns = false
			thorn.desired_direction = desired_direction.rotated(dir)
			thorn.seed_slots = seed_slots
			thorn.slot_index = slot_index
			thorn.seed_slot_number = seed_slot_number
			thorn.ignore_first_collision = ignore_first_collision
			thorn.transferred_speed_multiplier *= transferred_speed_multiplier
			thorn.transferred_range_multiplier *= transferred_range_multiplier
			thorn.transferred_size_multiplier *= transferred_size_multiplier
			thorn.transferred_damage_multiplier *= transferred_damage_multiplier
			thorn.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
			thorn.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
			get_tree().current_scene.add_child.call_deferred(thorn)
			thorn.global_position = global_position
			weapon_fired.emit(thorn)
		
		if get_next_weapon():
			# shoot the next seed alongside the thorns
			var seed_directions = [-SPREAD * 3/2, -SPREAD * 1/2, SPREAD * 1/2, SPREAD * 3/2]
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
