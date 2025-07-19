extends Node

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const SHADE_SLASH_SPRITE = preload("res://Scenes/Passives/Effects/Shade Slash Sprite.tscn")

var player
var shader
var original_contact_damage
var time = Timer.new()
var is_dashing: bool
var sprite
var DAMAGE: float = 50

func _ready():
	player = get_parent().get_parent()
	shader = player.material
	add_child(time)
	time.one_shot = true
	time.wait_time = 0.25
	
	time.timeout.connect(slash_timeout)
	player.has_collided.connect(slash_contact)
	if player == Targets.get_player():
		player.dashed.connect(slash)

func slash():
	time.start()
	
	Game.audio_manager.play(Game.audio_manager.whoosh)
	Game.audio_manager.play(Game.audio_manager.slash_2)
	
	if not sprite:
		sprite = SHADE_SLASH_SPRITE.instantiate()
		player.add_child(sprite)
	
	var splash = SPLASH.instantiate()
	splash.size = 0.4
	splash.source = player
	splash.modulate = "000000"
	splash.z_index = -1
	get_tree().current_scene.add_child(splash)
	splash.global_position = player.global_position
	
	if not is_dashing:
		
		is_dashing = true # prevent stacking the damage if dashing too fast

func slash_contact(enemy):
	if not is_dashing:
		return
	
	Game.audio_manager.play(Game.audio_manager.slash)
	Game.audio_manager.play(Game.audio_manager.smack_2)
	
	Targets.get_camera().add_trauma(0.2)
	
	if is_instance_valid(enemy) and (enemy.is_in_group("Enemy") or enemy.is_in_group("Dummies")):
		# deal damage to the enemy
		var _player = Targets.get_player()
		enemy._enemy_stats.take_damage(DAMAGE * (1 + _player._player_stats.stats["Weapon_Damage"]["+"]) \
				* _player._player_stats.stats["Weapon_Damage"]["x"])
		
		var splash = SPLASH.instantiate()
		splash.size = 0.5
		splash.source = player
		splash.modulate = "000000"
		splash.z_index = -1
		get_tree().current_scene.add_child(splash)
		splash.global_position = player.global_position

func slash_timeout():
	if sprite:
		sprite.queue_free()
		sprite = null
	
	Game.audio_manager.play(Game.audio_manager.slash_2)
	
	var splash = SPLASH.instantiate()
	splash.size = 0.65
	splash.source = player
	splash.modulate = "000000"
	splash.z_index = -1
	get_tree().current_scene.add_child(splash)
	splash.global_position = player.global_position
	
	is_dashing = false
