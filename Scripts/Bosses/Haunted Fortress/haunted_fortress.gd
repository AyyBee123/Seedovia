extends "res://Scripts/Bosses/boss.gd"

signal animation_done

@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var resource_preloader := $ResourcePreloader
@onready var light_beam_points = $"Light Beam Points".get_children()
@onready var marker_2d = $Marker2D
@onready var mouth_slam_SFX = $HauntedFortressMouthSlam
@onready var bfg_SFX = $Bfg
@onready var rumble_SFX = $Rumble
@onready var humming_SFX = $Humming
@onready var vacuum_SFX = $Vacuum
@onready var _state_machine = $StateMachine
@onready var laser_time = $"Laser Time"
@onready var suck_time = $"Suck Time"
@onready var suck_rock_time = $"Suck Rock Time"
@onready var ghost_time = $"Ghost Time"

var vacuum_db
var humming_db
var humming_volume

var current_random_value := -1

func _ready():
	super._ready()
	vacuum_db = vacuum_SFX.volume_db
	humming_db = humming_SFX.volume_db

func idle():
	vacuum_SFX.volume_db -= get_physics_process_delta_time() * 200
	humming_SFX.volume_db -= get_physics_process_delta_time() * 200
	if vacuum_SFX.volume_db <= -40:
		vacuum_SFX.stop()
	if humming_SFX.volume_db <= -40:
		humming_SFX.stop()

func laser():
	pass

func ghosts():
	if humming_SFX.volume_db < humming_db: # to not mess with the volume increase overtime
		humming_SFX.volume_db = humming_db

func suck():
	vacuum_SFX.volume_db = vacuum_db

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "Laser Beginning":
		if $AnimatedSprite2D.frame == 2: # gate closing sound
			mouth_slam_SFX.play()
		if $AnimatedSprite2D.frame == 4: # rumble (buildup) sound
			rumble_SFX.play()
		if $AnimatedSprite2D.frame == 30: # start of the laser fire animation
			if rumble_SFX.playing:
				rumble_SFX.stop()
			bfg_SFX.play()
			var laser = $ResourcePreloader.get_resource("Laser").instantiate()
			laser.damage = _enemy_stats.weapon_damage
			laser.range = _enemy_stats.weapon_range
			laser.speed = _enemy_stats.weapon_speed
			laser.source = self
			get_tree().current_scene.add_child(laser)
			laser.global_position = $Marker2D.global_position
	if $AnimatedSprite2D.animation == "Ghosts":
		if not humming_SFX.playing:
			humming_SFX.play()
		# start at really low humming volume and quickly increase it
		humming_SFX.volume_db = min(humming_SFX.volume_db + get_physics_process_delta_time() * 200, -10)
		# make the light beam on the boss' face
		var light_beam = $ResourcePreloader.get_resource("Light Beam").instantiate()
		get_tree().current_scene.add_child(light_beam)
		var rnd = randi_range(0, light_beam_points.size() - 1)
		while rnd == current_random_value: # prevents the same number from occuring twice in a row
			rnd = randi_range(0, light_beam_points.size() - 1)
		light_beam.global_position = light_beam_points[rnd].global_position
		current_random_value = rnd
		# make the light beam attack that will damage the player
		var light_attack = $ResourcePreloader.get_resource("Light Attack").instantiate()
		get_tree().current_scene.add_child(light_attack)
		# 702 is half the width of the floor tileset, minus the width of the beam (768 - 64)
		light_attack.global_position.x = randf_range(-704, 704)
		# -96 is the position of the top of the floor tile, and 352 is the position of the bottom of the floor tile
		light_attack.global_position.y = randf_range(-96, 352)
	if $AnimatedSprite2D.animation == "Suck Beginning":
		if $AnimatedSprite2D.frame == 0:
			if vacuum_SFX.playing:
				vacuum_SFX.stop()
		if $AnimatedSprite2D.frame == 1:
			if not vacuum_SFX.playing:
				vacuum_SFX.play()
	if $AnimatedSprite2D.animation == "Suck":
		_enemy_stats.damage = 1
		var player_direction = player.global_position.direction_to($Marker2D.global_position)
		player.velocity += player_direction.normalized() * 200
		if $AnimatedSprite2D.frame % 1 == 0 and not suck_rock_time.is_stopped():
			# make the rock projectile
			var rock = $ResourcePreloader.get_resource("Rock").instantiate()
			# make the random x position for the rock to spawn at
			var x_pos = randf_range(-768, 768)
			rock.damage = 1
			rock.range = 999999
			rock.speed = 400
			rock.direction = Vector2(x_pos, 384).direction_to($Marker2D.global_position)
			rock.destination = $Marker2D.global_position
			get_tree().current_scene.add_child(rock)
			rock.global_position = Vector2(x_pos, 384)

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Laser Beginning":
		laser_time.start()
		animated_sprite_2d.play("Laser")
	
	if animated_sprite_2d.animation == "Ghosts Beginning":
		ghost_time.start()
		animated_sprite_2d.play("Ghosts")
	
	if animated_sprite_2d.animation == "Suck Beginning":
		suck_time.start()
		suck_rock_time.start()
		animated_sprite_2d.play("Suck")
	
	if animated_sprite_2d.animation == "Laser End":
		_state_machine.set_state(_state_machine.states.idle)
	if animated_sprite_2d.animation == "Ghosts End":
		_state_machine.set_state(_state_machine.states.idle)
	if animated_sprite_2d.animation == "Suck End":
		_state_machine.set_state(_state_machine.states.idle)

func _on_laser_time_timeout():
	animated_sprite_2d.play("Laser End")
	var laser_instance = get_tree().get_first_node_in_group("Haunted Fortress Laser")
	laser_instance.disappear()

func _on_suck_time_timeout():
	animated_sprite_2d.play("Suck End")

func _on_ghost_time_timeout():
	animated_sprite_2d.play("Ghosts End")
