extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var delay = $Delay
@onready var roar_time = $"Roar Time"
@onready var explosion_rate = $"Explosion Rate"
@onready var roar_SFX = $DragonRoarFar

const EXPLOSION = preload("res://Scenes/Passives/Effects/Explosion.tscn")

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
	var explosion = EXPLOSION.instantiate()
	explosion.damage = DAMAGE
	explosion.size = BLAST_RADIUS
	explosion.source = self
	explosion.modulate = Color(colors.pick_random())
	explosion.z_index = z_index + 1
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
