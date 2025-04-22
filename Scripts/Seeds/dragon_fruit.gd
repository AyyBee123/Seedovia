extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var delay = $Delay
@onready var roar_time = $"Roar Time"
@onready var explosion_rate = $"Explosion Rate"
@onready var roar_SFX = $DragonRoarFar

const NON_WEAPON_EFFECT_EXPLOSION = preload("res://Scenes/Passives/Effects/Non-Weapon Effect Explosion.tscn")

const NUMBER_OF_EXPLOSIONS = 20

var explosion_count: int = 0
var colors = ["cccccc", "558d0e", "1111b3", "62d2e9", "f1e959", "ec5419"]
var radius
var _roar: bool

func _ready():
	randomize()
	super._ready()
	radius = RANGE / 2

func _physics_process(delta):
	super._physics_process(delta)
	
	if _roar and explosion_count < NUMBER_OF_EXPLOSIONS and explosion_rate.is_stopped():
		explosion_rate.start(1.0 / (FIRE_RATE * 16))
		var amount = randi_range(1, 2)
		for i in amount:
			weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
			shoot_next_weapon()
		explode()
		explosion_count += 1
	
	if explosion_count >= NUMBER_OF_EXPLOSIONS:
		queue_free.call_deferred()

func explode():
	var explosion = NON_WEAPON_EFFECT_EXPLOSION.instantiate()
	if get_node_or_null("Passives"):
		for passive in $Passives.get_children():
			explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.BASE_DAMAGE = DAMAGE
	explosion.BASE_SIZE = BLAST_RADIUS
	explosion.z_index = z_index + 1
	explosion.collisions = collisions
	explosion.get_node("AnimatedSprite2D").self_modulate = colors.pick_random()
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	call_deferred("create_child", explosion)

func create_child(child):
	SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion)
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * radius

func _collide(body):
	deceleration.stop()
	_on_deceleration_timeout()

func update_position(delta):
	current_velocity = direction * SPEED * deceleration.time_left
	position += current_velocity * delta

func _on_deceleration_timeout():
	delay.start()

func _on_delay_timeout():
	SfxDeconflicter.play(roar_SFX)
	roar_time.start()

func _on_roar_time_timeout():
	_roar = true
