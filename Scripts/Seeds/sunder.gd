extends "res://Scripts/Seeds/seed_template.gd"

const SUNDER_DIST = 35
const SEED_DIST = SUNDER_DIST * 2

@onready var resource_preloader = $ResourcePreloader

var distance_threshold: float = 0
var seed_distance_threshold: float = 0

func _ready():
	super._ready()
	$Hitbox.set_collision_mask(1)

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	distance_threshold += distance_travelled
	seed_distance_threshold += distance_travelled
	if total_distance >= RANGE:
		queue_free.call_deferred()
	if distance_threshold >= SUNDER_DIST:
		explode()
		distance_threshold = 0
	if seed_distance_threshold >= SEED_DIST:
		weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		shoot_next_weapon()
		seed_distance_threshold = 0

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	queue_free.call_deferred()

func explode():
	var explosion = resource_preloader.get_resource("Non-Weapon Effect Explosion").instantiate()
	if get_node_or_null("Passives"):
		for passive in $Passives.get_children():
			explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.BASE_DAMAGE = BASE_DAMAGE
	explosion.BASE_SIZE = BASE_BLAST_RADIUS * BASE_SIZE
	explosion.collisions = collisions
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.SADDLE_BROWN
	SfxDeconflicter.play(Game.audio_manager.sunder_explosion)
	call_deferred("create_child", explosion)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = global_position
