extends "res://Scripts/Passives/Classes/passive_tally.gd"

@onready var resource_preloader := $ResourcePreloader

@export var damage_multiplier: float = 3
@export var explosion_size_multiplier: float = 1.5

func _ready():
	super._ready()
	source.weapon_fired.connect(transfer_passive)

func add_tally(weapon = null):
	super.add_tally()
	if tally_count >= 3:
		tally_count = 0
		explode()

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null or weapon.is_in_group("Weapon Effect"):
		return
	if weapon.get_node("Passives").has_node("ExplosiveTrigger"): # prevent duplicates
		return
	# make a new banana mine passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(duplicate())

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.object = source
	explosion.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
	explosion.size = player._player_stats.get_stat("Weapon_Blast_Radius") * explosion_size_multiplier
	spawn_explosion.call_deferred(explosion)

func spawn_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = source.global_position
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.GOLD
