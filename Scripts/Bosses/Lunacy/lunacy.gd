extends "res://Scripts/Bosses/boss.gd"

@onready var lunacy_projectile := preload("res://Scenes/Enemies/Weapons/Lunacy Projectile.tscn")
@onready var tooth_projectile := preload("res://Scenes/Enemies/Weapons/Tooth.tscn")
@onready var fire_rate := $"Fire Rate"
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var lunacy_duration = $"Lunacy Duration"
@onready var laser_animation = $"Lasers/Laser Animation"
@onready var tooth_positions = $"Tooth Positions".get_children()
@onready var space_laser_SFX = $SpaceLaser
@onready var space_laser_noise_SFX = $SpaceLaserNoise
@onready var bubble_pop_SFX = $BubblePop
@onready var disappear_SFX = $Disappear
@onready var reappear_SFX = $Reappear

var lunacy_proj_pool := []
var teeth_pool := []
var pos_x: float
var pos_y: float
var positions := ["UP", "DOWN", "LEFT", "RIGHT"]
var pos
var fade: float = 1
var _in_lunacy: bool
var _used_WTF: bool
var _reappear_sound_played: bool

var teeth_finished: bool
var what_finished: bool
var laser_finished: bool
var tahw_finished: bool
var lunacy_almost_finished: bool
var lunacy_finished: bool

func _physics_process(delta):
	super._physics_process(delta)

func idle():
	lunacy_duration.stop()
	lunacy_almost_finished = false
	$Lasers.visible = false
	_reappear_sound_played = false

func teeth():
	pass

func what():
	_used_WTF = true

func what_idle():
	pass

func laser():
	$Lasers.visible = true
	$Lasers.scale = Vector2.ONE
	if not laser_animation.is_playing() and not laser_finished:
		laser_animation.play("Lasers")

func finish_laser():
	laser_finished = true
	$Lasers.scale = Vector2.ZERO
	animated_sprite_2d.play("Laser End")

func tahw():
	pass

func lunacy():
	animated_sprite_2d.material.set("shader_parameter/fade", fade)
	if not lunacy_almost_finished:
		fade = max(fade - 2 * get_physics_process_delta_time(), 0)
	if lunacy_duration.is_stopped() and fade <= 0:
		$"Enemy Hitbox/CollisionPolygon2D".disabled = true
		_in_lunacy = true
		lunacy_duration.start()
	if lunacy_almost_finished:
		lunacy_duration.stop()
		await get_tree().create_timer(5).timeout
		if not _reappear_sound_played:
			reappear_SFX.play()
			_reappear_sound_played = true
		fade = min(fade + 2 * get_physics_process_delta_time(), 1)
	if lunacy_almost_finished and fade >= 1:
		$"Enemy Hitbox/CollisionPolygon2D".disabled = false
		_in_lunacy = false
		lunacy_finished = true
	if not lunacy_duration.is_stopped():
		fire_lunacy()

func _on_lunacy_duration_timeout():
	lunacy_almost_finished = true

func _on_animated_sprite_2d_animation_changed():
	pass

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "WTF":
		what_finished = true
	if animated_sprite_2d.animation == "Teeth":
		teeth_finished = true
	if animated_sprite_2d.animation == "FTW":
		tahw_finished = true
	if animated_sprite_2d.animation == "Laser Beginning":
		animated_sprite_2d.play("Laser")

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.animation == "WTF":
		if animated_sprite_2d.frame == 6:
			animation_player.play("WTF")
	if animated_sprite_2d.animation == "FTW":
		if animated_sprite_2d.frame == 4:
			animation_player.play_backwards("WTF")
	if animated_sprite_2d.animation == "Teeth":
		var proj = []
		match animated_sprite_2d.frame:
			2:
				bubble_pop_SFX.play()
				proj.append(pull_tooth_from_pool(tooth_positions[4].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[7].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[12].global_position, Vector2.UP))
			3:
				bubble_pop_SFX.play()
				proj.append(pull_tooth_from_pool(tooth_positions[2].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[5].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[14].global_position, Vector2.UP))
			4:
				bubble_pop_SFX.play()
				proj.append(pull_tooth_from_pool(tooth_positions[1].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[9].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[10].global_position, Vector2.UP))
			5:
				bubble_pop_SFX.play()
				proj.append(pull_tooth_from_pool(tooth_positions[0].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[6].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[13].global_position, Vector2.UP))
			6:
				bubble_pop_SFX.play()
				proj.append(pull_tooth_from_pool(tooth_positions[3].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[8].global_position, Vector2.DOWN))
				proj.append(pull_tooth_from_pool(tooth_positions[11].global_position, Vector2.UP))
				proj.append(pull_tooth_from_pool(tooth_positions[15].global_position, Vector2.UP))
		for i in proj:
			if not i.get_parent():
				get_tree().current_scene.add_child(i)
			else:
				i._ready()

## when the object is "destroyed", add it back to the pool
## also add a couple to the pool on _ready
func add_to_pool(object: Node2D, object_pool: Array) -> void:
	object_pool.append(object)

## pull the object from the pool and use it in the scene (when firing a projectile, for instance)
func pull_lunacy_from_pool() -> Node2D:
	var object: Node2D
	if lunacy_proj_pool.is_empty():
		object = lunacy_projectile.instantiate()
	else:
		object = lunacy_proj_pool[0]
		lunacy_proj_pool.remove_at(0)
	object.source = self
	object.global_position = Vector2(pos_x, pos_y)
	object._used_WTF = _used_WTF
	match pos:
		"UP":
			object.direction = Vector2.DOWN
		"DOWN":
			object.direction = Vector2.UP
		"LEFT":
			object.direction = Vector2.RIGHT
		"RIGHT":
			object.direction = Vector2.LEFT
	return object

func pull_tooth_from_pool(pos: Vector2, dir: Vector2) -> Node2D:
	var object: Node2D
	if teeth_pool.is_empty():
		object = tooth_projectile.instantiate()
	else:
		object = teeth_pool[0]
		teeth_pool.remove_at(0)
	object.source = self
	object.global_position = pos
	object.starting_position = pos
	object.direction = dir.rotated(randf_range(-PI/3, PI/3))
	return object

func fire_lunacy():
	if not fire_rate.is_stopped():
		return
	fire_rate.start()
	
	pos = positions.pick_random()
	match pos:
		"UP":
			pos_x = randi_range(-6, 5) * 128 + 64
			pos_y = -640
		"DOWN":
			pos_x = randi_range(-6, 5) * 128 + 64
			pos_y = 640
		"LEFT":
			pos_x = -1050
			pos_y = randi_range(-3, 2) * 128 + 64
		"RIGHT":
			pos_x = 1050
			pos_y = randi_range(-3, 2) * 128 + 64
	
	var proj = pull_lunacy_from_pool()
	if not proj.get_parent(): # if it's not already added as a child
		get_tree().current_scene.add_child(proj)
	else:
		proj._ready()

func spawn_damage_number(damage: float):
	if _in_lunacy:
		return
	var value = str(round(damage))
	var pos = global_position
	var height = 20
	var spread = 75
	var damage_text = damage_number.instantiate()
	get_tree().current_scene.add_child(damage_text, true)
	damage_text.global_position = global_position
	damage_text.set_and_animate_damage(damage, pos, height, spread)

func play_laser_sound():
	space_laser_SFX.play()

func play_noise_sound():
	space_laser_noise_SFX.play()
