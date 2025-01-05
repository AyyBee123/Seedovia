extends "res://Scripts/Seeds/seed_template.gd"

@onready var resource_preloader = $ResourcePreloader
@onready var animation_player = $AnimationPlayer

const NUMBER_OF_SEEDS = 6
var _set_as_visible: bool

#TODO: add functionality to launch the corn to an enemy in front of the player when aim assist is on (or on controller)
func _ready():
	super._ready()
	visible = false # make the first frame invisible to remove the jitter visual effect
	animation_player.play("new_animation")

func update_position(delta):
	current_velocity = direction * player._player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta
	if current_velocity.x < 0:
		scale.x = -abs(scale.x) # keep the x-scale negative
	else:
		scale.x = abs(scale.x) # keep the x-scale positive
	if not _set_as_visible:
		visible = true
		_set_as_visible = true

func explode():
	has_collided.emit(null)
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
	explosion.size = player._player_stats.get_stat("Weapon_Blast_Radius") * blast_radius_multiplier
	explosion.get_node("AnimatedSprite2D").self_modulate = Color("c69b30") # match the corn's shaded color
	SfxDeconflicter.play(Game.audio_manager.corn_mild_explosion)
	create_explosion.call_deferred(explosion)
	if get_next_weapon():
		for i in NUMBER_OF_SEEDS:
			weapon_direction = Vector2.RIGHT.rotated(i * TAU/NUMBER_OF_SEEDS)
			shoot_next_weapon()
	queue_free.call_deferred()

func create_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = self.global_position

func _on_animation_player_animation_finished(anim_name):
	explode()

func _collide(body):
	pass

func travelled_distance():
	pass
