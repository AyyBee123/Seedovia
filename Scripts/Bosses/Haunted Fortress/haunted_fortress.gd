extends "res://Scripts/Bosses/boss.gd"

signal animation_done

@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var resource_preloader := $ResourcePreloader

func idle():
	pass

func laser():
	pass

func _on_animated_sprite_2d_animation_finished():
	animation_done.emit() # this is for the state machine to see if animation is done

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "Laser":
		if $AnimatedSprite2D.frame == 30: # start of the laser fire animation
			var laser = $ResourcePreloader.get_resource("Laser").instantiate()
			laser.damage = _enemy_stats.weapon_damage
			laser.range = _enemy_stats.weapon_range
			laser.speed = _enemy_stats.weapon_speed
			get_tree().current_scene.add_child(laser)
			laser.global_position = $Marker2D.global_position
		if $AnimatedSprite2D.frame == 65: # end of the laser fire animation
			var laser_instance = get_tree().get_first_node_in_group("Haunted Fortress Laser")
			laser_instance.disappear()
