extends "res://Scripts/Seeds/seed_template.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	explode()
	
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.bubble_pop_2)
	
	weapon_direction = direction
	shoot_next_weapon()

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func shrub_bush(): # duck typing
	pass

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.3 * SIZE
	splash.source = self
	splash.modulate = Color("59a029")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func _on_bullet_hitbox_area_entered(area):
	if area.is_in_group("Enemy Projectile"):
		area.get_parent().queue_free()
		
		animated_sprite_2d.play("Deflect")
		SfxDeconflicter.play(Game.audio_manager.ding)
		
		weapon_direction = direction
		shoot_next_weapon()

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("Default")
