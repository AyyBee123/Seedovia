extends "res://Scripts/Bosses/boss.gd"

signal animation_done

@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var resource_preloader := $ResourcePreloader
@onready var light_beam_points = $"Light Beam Points".get_children()
@onready var marker_2d = $Marker2D
var current_random_value := -1

func idle():
	pass

func laser():
	pass

func ghosts():
	pass

func suck():
	pass

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "Laser":
		if $AnimatedSprite2D.frame == 30: # start of the laser fire animation
			var laser = $ResourcePreloader.get_resource("Laser").instantiate()
			laser.damage = _enemy_stats.weapon_damage
			laser.range = _enemy_stats.weapon_range
			laser.speed = _enemy_stats.weapon_speed
			laser.source = self
			get_tree().current_scene.add_child(laser)
			laser.global_position = $Marker2D.global_position
		if $AnimatedSprite2D.frame == 65: # end of the laser fire animation
			var laser_instance = get_tree().get_first_node_in_group("Haunted Fortress Laser")
			laser_instance.disappear()
	if $AnimatedSprite2D.animation == "Ghosts":
		if $AnimatedSprite2D.frame > 2 and $AnimatedSprite2D.frame <= 63:
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
	if $AnimatedSprite2D.animation == "Suck":
		if $AnimatedSprite2D.frame > 43:
			_enemy_stats.damage = 0
		elif $AnimatedSprite2D.frame >= 20:
			_enemy_stats.damage = 1
			var player_direction = player.global_position.direction_to($Marker2D.global_position)
			player.global_position += player_direction.normalized() * 12
		elif $AnimatedSprite2D.frame >= 3:
			_enemy_stats.damage = 1
			var player_direction = player.global_position.direction_to($Marker2D.global_position)
			player.global_position += player_direction.normalized() * 12
			if $AnimatedSprite2D.frame % 1 == 0:
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
