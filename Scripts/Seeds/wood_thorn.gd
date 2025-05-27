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
			shoot_current_seed(WOOD_THORN.instantiate(), desired_direction.rotated(dir))
		
		if get_next_weapon():
			# shoot the next seed alongside the thorns
			var seed_directions = [-SPREAD * 1/2, SPREAD * 1/2]
			for dir in seed_directions:
				weapon_direction = desired_direction.rotated(dir)
				shoot_next_weapon()
			BASE_FIRE_RATE = 1.0 / (get_next_weapon().instantiate().BASE_FIRE_RATE * 1.25)
			if previous_weapon and "fire_rate" in previous_weapon:
				previous_weapon.fire_rate.start(FIRE_RATE)

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
	destroy()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.25 * SIZE
	splash.source = self
	splash.modulate = Color("4f2e27")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func shoot_current_seed(instantiated_weapon, _desired_direction = desired_direction, pos = global_position):
	instantiated_weapon._spawn_more_thorns = false
	super.shoot_current_seed(instantiated_weapon, _desired_direction, pos)
