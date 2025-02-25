extends Node

const EXPLOSION = preload("res://Scenes/Passives/Effects/Explosion.tscn")
const RAINBOW_COLOR = preload("res://Scenes/Seeds/Effects/Rainbow Color.tscn")

var weapon
var pos
var DAMAGE
var _has_lifetime: bool

func _ready():
	weapon = get_parent()
	weapon.has_collided.connect(explode)
	if weapon.get_node_or_null("Lifetime"):
		_has_lifetime = true

func _physics_process(delta):
	pos = weapon.global_position
	if _has_lifetime:
		weapon.lifetime.start() # keep starting the lifetime timer to prevent seed from being destroyed

func explode(body):
	var explosion = EXPLOSION.instantiate()
	explosion.damage = DAMAGE
	explosion.size = 0.5 * weapon.SIZE
	explosion.source = weapon
	explosion.add_child(RAINBOW_COLOR.instantiate())
	call_deferred("create_child", explosion)

func create_child(child):
	SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion_2)
	SfxDeconflicter.play(Game.audio_manager.sparkle_lower_vol)
	get_tree().current_scene.add_child(child)
	child.global_position = pos

func _on_timer_timeout():
	explode(null)
	weapon.queue_free.call_deferred()
