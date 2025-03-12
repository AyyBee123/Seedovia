extends Sprite2D

var position_initialized = false
var direction: Vector2
var object
var spread: float
var speed: float
var weapon_direction: Vector2
var parent_banana
var damage_multiplier: float = 1

var DAMAGE: float
var BLAST_RADIUS: float
var FIRE_RATE: float
var RANGE: float
var SIZE: float
var SPEED: float

signal weapon_fired(weapon)
signal has_collided(object)

@onready var player = Targets.get_player()
@onready var _player_stats = player._player_stats
@onready var projectile_speed_timer := $"Projectile Deceleration"
@onready var life_time := $Lifetime
@onready var resource_preloader := $ResourcePreloader
@onready var mild_explosion_SFX = $MildExplosion

func _physics_process(delta):
	update_position(delta)

func banana():
	pass

func update_position(delta):
	var current_velocity: Vector2 = direction * speed * projectile_speed_timer.time_left
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func _on_enemy_detect_area_entered(area):
	explode()
	
func _on_wall_detect_body_entered(body):
	has_collided.emit(body)
	explode()

func _on_lifetime_timeout():
	explode()
	
func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = DAMAGE
	explosion.size = BLAST_RADIUS
	explosion.source = self
	explosion.modulate = Color.YELLOW
	for passive in $Passives.get_children():
		if passive.name == "ExplosiveTrigger":
			continue
		if passive.name == "HuraCrepitans":
			continue
		explosion.get_node("Passives").add_child(passive.duplicate())
	call_deferred("create_child", explosion)
	SfxDeconflicter.play(mild_explosion_SFX)
	set_physics_process(false)
	if mild_explosion_SFX.playing:
		visible = false
		await mild_explosion_SFX.finished
	queue_free.call_deferred()
	
func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
	weapon_direction = direction
	weapon_fired.emit(child)
