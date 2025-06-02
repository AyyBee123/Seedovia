extends "res://Scripts/Seeds/seed_template.gd"

const NON_WEAPON_EFFECT_EXPLOSION = preload("res://Scenes/Passives/Effects/Non-Weapon Effect Explosion.tscn")
const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

func _ready():
	randomize()
	super._ready()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta
	
	flip_h = direction.x > 0
	$Sprite2D.rotation += TAU * delta * sign(direction.x)

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion_2)
	SfxDeconflicter.play(Game.audio_manager.quiet_thud)
	splash()
	destroy()

func splash():
	var splash = SPLASH.instantiate()
	splash.size = 0.4 * SIZE
	splash.source = self
	splash.modulate = Color("9e7a63")
	call_deferred("create_splash", splash)

func create_splash(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func explode():
	var explosion = NON_WEAPON_EFFECT_EXPLOSION.instantiate()
	if get_node_or_null("Passives"):
		for passive in $Passives.get_children():
			explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.BASE_DAMAGE = DAMAGE
	explosion.BASE_SIZE = BLAST_RADIUS * 0.4
	explosion.collisions = collisions
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	explosion.get_node("AnimatedSprite2D").self_modulate = Color("9e7a63")
	call_deferred("create_child", explosion)
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	shoot_next_weapon()

func create_child(child):
	if randf() < 0.5:
		SfxDeconflicter.play(Game.audio_manager.mushroom_boing)
	else:
		SfxDeconflicter.play(Game.audio_manager.mushroom_boing_2)
	SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion_2)
	SfxDeconflicter.play(Game.audio_manager.quiet_thud)
	visible = false
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
