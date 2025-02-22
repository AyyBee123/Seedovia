extends Node

var source
var collided_object
var source_passives
var pos
var player

@onready var resource_preloader = $ResourcePreloader

var explosion_size_multiplier = 0.25
var damage_multiplier = 0.4

func _ready():
	player = Targets.get_player()
	source = get_parent().get_parent()
	source_passives = source.get_node("Passives").get_children()
	source.has_collided.connect(collide)
	source.weapon_fired.connect(transfer_passive)

func collide(object):
	collided_object = object
	pos = source.global_position
	trigger(source)

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	# make a new banana mine passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(self.duplicate())
	source_passives = source.get_node("Passives").get_children()

func trigger(weapon = null):
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	for passive in source_passives:
		if passive.has_method("hura_crepitans"):
			continue
		if passive.has_method("chain_lightning"):
			continue
		explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.object = source
	explosion.damage = source.DAMAGE
	explosion.damage_multiplier = damage_multiplier
	explosion.size = source.BLAST_RADIUS * explosion_size_multiplier
	spawn_explosion.call_deferred(explosion)

func spawn_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = source.global_position
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.BURLYWOOD

func hura_crepitans(): # duck typing
	pass
