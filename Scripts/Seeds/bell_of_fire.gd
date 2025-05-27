extends "res://Scripts/Seeds/seed_template.gd"

const NON_WEAPON_EFFECT_EXPLOSION = preload("res://Scenes/Passives/Effects/Non-Weapon Effect Explosion.tscn")
const BELL_OF_FIRE_POOL = preload("res://Scenes/Seeds/Effects/Bell of Fire Pool.tscn")

func _physics_process(delta):
	super._physics_process(delta)
	$Sprite2D.rotation += PI * delta

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	explode()

func explode():
	var explosion = NON_WEAPON_EFFECT_EXPLOSION.instantiate()
	if get_node_or_null("Passives"):
		for passive in $Passives.get_children():
			explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.BASE_DAMAGE = DAMAGE
	explosion.BASE_SIZE = BLAST_RADIUS
	explosion.collisions = collisions
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	explosion.get_node("AnimatedSprite2D").self_modulate = Color("de4b13")
	SfxDeconflicter.play(Game.audio_manager.fire_explosion)
	call_deferred("create_child", explosion)
	if source == player: # spawn the fire pool only if shot by the player or a player seed
		shoot_current_seed(BELL_OF_FIRE_POOL.instantiate(), direction)
	destroy()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func shoot_current_seed(instantiated_weapon, _desired_direction = desired_direction, pos = global_position):
	instantiated_weapon.scale *= BLAST_RADIUS
	super.shoot_current_seed(instantiated_weapon, _desired_direction, pos)
