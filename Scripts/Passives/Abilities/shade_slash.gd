extends Node

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
const SHADE_SLASH_SPRITE = preload("res://Scenes/Passives/Effects/Shade Slash Sprite.tscn")

var player
var shader
var original_contact_damage
var time = Timer.new()
var is_dashing: bool
var sprite

func _ready():
	player = get_parent().get_parent()
	shader = player.material
	add_child(time)
	time.one_shot = true
	time.wait_time = 0.25
	
	time.timeout.connect(slash_timeout)
	player.contact_damage_dealt.connect(slash_contact)
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
		original_contact_damage = player._player_stats.contact_damage # get contact damage before dashing
		player._player_stats.contact_damage += player.DAMAGE * 2
		is_dashing = true # prevent stacking the damage if dashing too fast

func slash_contact(enemy):
	if not is_dashing:
		return
	
	Game.audio_manager.play(Game.audio_manager.slash)
	Game.audio_manager.play(Game.audio_manager.smack_2)
	
	if is_instance_valid(enemy):
		var splash = SPLASH.instantiate()
		splash.size = 0.5
		splash.source = player
		splash.modulate = "000000"
		splash.z_index = -1
		get_tree().current_scene.add_child(splash)
		splash.global_position = player.global_position

func slash_timeout():
	player._player_stats.contact_damage = original_contact_damage
	
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
