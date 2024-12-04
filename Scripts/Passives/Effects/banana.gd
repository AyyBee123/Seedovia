extends Sprite2D

var position_initialized = false
var direction
var damage: float
var explosion_size: float
var spread: float
var speed: float
var weapon_direction: Vector2
var source_pos
var previous_weapon
var damage_multiplier

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall
signal attempted_fire # signal for attempting to fire the next seed (even if the next seed is null)

@onready var player = Targets.get_player()
@onready var _player_stats = player._player_stats
@onready var projectile_speed_timer := $"Projectile Deceleration"
@onready var life_time := $Lifetime
@onready var resource_preloader := $ResourcePreloader
@onready var mild_explosion_SFX = $MildExplosion

func _ready():
	previous_weapon.weapon_fired.emit(self)
	global_position = source_pos
	spread = deg_to_rad(randf_range(-20,20))

func banana():
	pass

func _physics_process(delta):
	direction = weapon_direction.normalized().rotated(spread)
	update_position(delta)

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
	explosion.damage = damage
	explosion.size = explosion_size
	explosion.source = self
	explosion.modulate = Color.YELLOW
	for _passive in $Passives.get_children():
		if _passive.name == "ExplosiveTrigger":
			continue
		if _passive.name == "HuraCrepitans":
			continue
		explosion.get_node("Passives").add_child(_passive.duplicate())
	call_deferred("create_child", explosion)
	SfxDeconflicter.play(mild_explosion_SFX)
	set_physics_process(false)
	spawn_child_bananas()
	if mild_explosion_SFX.playing:
		visible = false
		await mild_explosion_SFX.finished
	queue_free.call_deferred()

func spawn_child_bananas():
	# split the banana mine into 3 smaller bananas with the indicated launch directions
	var directions = [Vector2.UP, Vector2(-sqrt(3)/2,0.5), Vector2(sqrt(3)/2,0.5)]
	spread = deg_to_rad(randf_range(-45, 45))
	for direction in directions:
		var banana_child = resource_preloader.get_resource("Banana Child").instantiate()
		for passive in $Passives.get_children():
			banana_child.get_node("Passives").add_child(passive.duplicate())
		banana_child.damage = damage
		banana_child.damage_multiplier = 0.35 * damage_multiplier
		banana_child.speed = speed
		banana_child.explosion_size = 0.65
		banana_child.direction = direction.rotated(spread)
		call_deferred("create_child", banana_child)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
	weapon_direction = direction.rotated(spread)
	attempted_fire.emit(child)
	weapon_fired.emit(child)
