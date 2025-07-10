extends "res://Scripts/Seeds/seed_template.gd"

@onready var pointer = %Pointer
@onready var marker_2d = %Marker2D
@onready var lifetime = $Lifetime

const NON_WEAPON_EFFECT_EXPLOSION = preload("res://Scenes/Passives/Effects/Non-Weapon Effect Explosion.tscn")

const NEXT_SEED_CHANCE = 0.15
var ROTATION_SPEED = 0.5
var tween

var rotation_speed: float
var starting_rotation: float
var t: float

func _ready():
	super._ready()
	randomize()
	lifetime.start(randf_range(0.25, 0.5) * sqrt(RANGE / 150))
	starting_rotation = PI/2 if randf() < 0.5 else -PI/2
	BASE_RANGE = BASE_RANGE * randf_range(0.25, 1.75)
	# divide by a small number to prevent the shot from going backwards
	pointer.rotation = direction.rotated(starting_rotation / 1.001).angle()

func update_position(delta):
	current_velocity = global_position.direction_to(marker_2d.global_position) * SPEED
	position += current_velocity * delta
	
	t += delta * 75 / RANGE # the more range, the longer it takes to finish rotating
	pointer.rotation = lerp_angle(pointer.rotation, direction.rotated(-starting_rotation).angle(), t)

func travelled_distance():
	pass

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	explode()

func explode():
	if randf() < NEXT_SEED_CHANCE:
		weapon_direction = Vector2.RIGHT.rotated(pointer.rotation)
		shoot_next_weapon()
	
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
	explosion.get_node("AnimatedSprite2D").self_modulate = Color("27419d")
	call_deferred("create_child", explosion)

func create_child(child):
	SfxDeconflicter.play(Game.audio_manager.blueberry_mild_explosion)
	SfxDeconflicter.play(Game.audio_manager.spore_pop)
	visible = false
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
	destroy()

func _exit_tree():
	if tween:
		tween.kill()

func _on_lifetime_timeout():
	explode()
