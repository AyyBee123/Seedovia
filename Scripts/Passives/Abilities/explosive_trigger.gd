extends "res://Scripts/Passives/Classes/passive_tally.gd"

@onready var resource_preloader := $ResourcePreloader
@export var explosion_size_multiplier: float = 1.5
var source_passives: Array

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
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	if weapon.get_node("Passives").has_node("ExplosiveTrigger"): # prevent duplicates
		return
	# make a new explosive trigger passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(duplicate())
	source_passives = source.get_node("Passives").get_children()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	for passive in source_passives:
		if passive.has_method("explosive_trigger"):
			continue
		if passive.has_method("hura_crepitans"):
			continue
		explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.object = source
	explosion.damage = source.DAMAGE
	explosion.damage_multiplier = 1
	explosion.size = source.BLAST_RADIUS * explosion_size_multiplier
	spawn_explosion.call_deferred(explosion)

func spawn_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = source.global_position
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.GOLD

func explosive_trigger():
	pass
