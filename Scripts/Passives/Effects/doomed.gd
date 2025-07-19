extends Node

const DOOM_SWORD = preload("res://Scenes/Passives/Effects/Doom Sword.tscn")
const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

var damage: float
var enemy
var is_doomed: bool
var sword

func _ready():
	enemy = get_parent()
	enemy._enemy_stats.spawn_damage_number.connect(stack_damage)

func _physics_process(delta):
	if sword:
		is_doomed = true
	else:
		is_doomed = false

func stack_damage(amount):
	damage += amount
	
	if is_doomed:
		return
	sword = DOOM_SWORD.instantiate()
	sword.target = enemy
	sword.doom_hit.connect(strike)
	enemy.add_child(sword)

func strike():
	var total_damage = damage
	enemy._enemy_stats.take_damage(total_damage)
	damage = 0
	Game.audio_manager.play(Game.audio_manager.slash_3)
	explode()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.6
	splash.source = self
	splash.modulate = Color("9f0012")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = enemy.global_position
