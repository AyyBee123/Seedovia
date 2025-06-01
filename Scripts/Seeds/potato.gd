extends "res://Scripts/Seeds/seed_template.gd"

@onready var fire_rate = $"Fire Rate"
@onready var firing_time = $"Firing Time"

const NON_WEAPON_EFFECT_EXPLOSION = preload("res://Scenes/Passives/Effects/Non-Weapon Effect Explosion.tscn")

const FIRE_RATE_MULTIPLIER = 4
const SPREAD = 5 * PI/12

func _ready():
	randomize()
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	if fire_rate.is_stopped() and not firing_time.is_stopped():
		weapon_direction = direction.rotated(randf_range(-SPREAD, SPREAD))
		shoot_next_weapon()

func initialize_location(weapon):
	super.initialize_location(weapon)
	fire_rate.start(1.0 / (FIRE_RATE_MULTIPLIER * weapon.FIRE_RATE))

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
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	explode()

func explode():
	var explosion = NON_WEAPON_EFFECT_EXPLOSION.instantiate()
	if get_node_or_null("Passives"):
		for passive in $Passives.get_children():
			explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.BASE_DAMAGE = DAMAGE
	explosion.BASE_SIZE = BLAST_RADIUS * 0.5
	explosion.collisions = collisions
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	explosion.get_node("AnimatedSprite2D").self_modulate = Color("ce9e54")
	call_deferred("create_child", explosion)

func create_child(child):
	SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion_2)
	SfxDeconflicter.play(Game.audio_manager.quiet_thud)
	visible = false
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
	destroy()

func travelled_distance():
	pass

func _on_animation_player_animation_finished(anim_name):
	explode()
