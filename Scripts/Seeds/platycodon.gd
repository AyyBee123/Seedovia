extends "res://Scripts/Seeds/seed_template.gd"

@onready var lifetime = $Lifetime

const NON_WEAPON_EFFECT_EXPLOSION = preload("res://Scenes/Passives/Effects/Non-Weapon Effect Explosion.tscn")

const ROTATION_SPEED = TAU
const NUMBER_OF_SEEDS: int = 2

var is_stuck: bool
var is_stuck_to_enemy: bool
var distance_to_enemy: Vector2
var enemy
var enemy_hitbox

func _ready():
	randomize()
	super._ready()

func _collide(body):
	if is_stuck:
		return
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		is_stuck_to_enemy = true
		enemy = body.get_parent()
		enemy_hitbox = body
		distance_to_enemy = enemy.global_position - global_position
		enemy._enemy_stats.take_damage(DAMAGE / 2)
	if body.is_in_group("Players"):
		body._player_stats.take_damage(1)
		explode()
		destroy()
	SfxDeconflicter.play(Game.audio_manager.hit_2)
	is_stuck = true
	lifetime.start()

func update_position(delta):
	if not is_stuck:
		current_velocity = direction * SPEED
		position += current_velocity * delta
		rotation += ROTATION_SPEED * delta * sign(direction.x)
	else:
		BASE_SPEED = 0
		if is_stuck_to_enemy:
			if not is_instance_valid(enemy):
				destroy()
				return
			global_position = enemy.global_position - distance_to_enemy
		scale += Vector2.ONE * delta

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
	explosion.get_node("AnimatedSprite2D").self_modulate = Color("7e6cdb")
	for i in NUMBER_OF_SEEDS:
		weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		shoot_next_weapon()
	call_deferred("create_child", explosion)

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func _on_lifetime_timeout():
	explode()

func create_child(child):
	SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion_2)
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
	destroy()
