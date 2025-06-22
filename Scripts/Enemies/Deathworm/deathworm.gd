extends "res://Scripts/Enemies/enemy.gd"

const DEATHWORM_BODY = preload("res://Scenes/Enemies/Deathworm Body.tscn")
const BULLET = preload("res://Scenes/Enemies/Weapons/Sucked Bullet.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var pointer = $Pointer
@onready var marker_2d = $Pointer/Marker2D
@onready var fire_rate = $"Fire Rate"
@onready var vacuum_SFX = $Vacuum

const MIN_DISTANCE = 24
const NUMBER_OF_SEGMENTS = 12
const OFFSET = 20
const NUMBER_OF_BULLETS = 24

var direction: Vector2
var rotation_speed: float = 2
var segments: Array
var leading_segment
var size = 1
var speed_multi = 0.25
var sucked_bullet_amount: int
var spawned_bullet_amount: int

func _ready():
	randomize()
	super._ready()
	
	for i in NUMBER_OF_SEGMENTS:
		var segment = DEATHWORM_BODY.instantiate()
		segment.source = self
		segment.direction = direction
		# assign the leading segment for each segment to directly follow
		if leading_segment:
			segment.leading_segment = segments[i - 1]
		else:
			segment.leading_segment = self
		size -= 0.05
		segment.MIN_DISTANCE = MIN_DISTANCE * size + 2
		segment.scale = scale * size
		get_tree().current_scene.add_child.call_deferred(segment)
		segment.global_position = global_position
		segments.append(segment)
		leading_segment = segment
	
	# look at the player's spawn point at the start to avoid turning when entering a new room
	pointer.rotation = global_position.direction_to(Vector2(0, 330)).angle()

func _physics_process(delta):
	super._physics_process(delta)
	
	if player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed * delta)
	
	speed_multi = min(speed_multi + delta, 1)

func idle():
	if sin(pointer.rotation) > 0:
		animated_sprite_2d.play("Idle")
	else:
		animated_sprite_2d.play("Idle Back")
	
	velocity = velocity.lerp(global_position.direction_to(marker_2d.global_position) * _enemy_stats.speed * speed_multi, \
			_enemy_stats.acceleration)

func suck():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	
	if player:
		var player_direction = player.global_position.direction_to(global_position)
		player.velocity += player_direction * 30

func random_spawn_point():
	var spawn_point: Vector2
	var s = randi_range(0, 3)
	var x = get_viewport_rect().size.x + OFFSET
	var y = get_viewport_rect().size.y + OFFSET
	match s:
		0: # top edge
			spawn_point = Vector2(randf_range(-x/2, x/2), -y/2)
		1: # bottom edge
			spawn_point = Vector2(randf_range(-x/2, x/2), y/2)
		2: # left edge
			spawn_point = Vector2(-x/2, randf_range(-y/2, y/2))
		3: # right edge
			spawn_point = Vector2(x/2, randf_range(-y/2, y/2))
	return spawn_point

func _on_fire_rate_timeout():
	if spawned_bullet_amount >= NUMBER_OF_BULLETS:
		return
	
	var bullet = BULLET.instantiate()
	bullet.damage = _enemy_stats.weapon_damage
	bullet.speed = _enemy_stats.weapon_speed
	bullet.range = _enemy_stats.weapon_range
	bullet.source = self
	get_tree().current_scene.add_child.call_deferred(bullet)
	bullet.global_position = random_spawn_point()
	spawned_bullet_amount += 1
	fire_rate.start()
