extends Sprite2D

@onready var resource_preloader = $ResourcePreloader
@onready var mild_explosion_SFX = $MildExplosion
@onready var passives = $Passives

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall

var damage_multiplier: float = 1.5
var first_seed
var number_of_shots: int = 6
var player
var player_passives
var _has_exploded := false
var weapon_direction: Vector2
var direction: Vector2

var DAMAGE: float
var BLAST_RADIUS: float
var FIRE_RATE: float
var RANGE: float
var SIZE: float
var SPEED: float

func _ready():
	first_seed = null if PlayerInventory.seeds.get(0) == null else PlayerInventory.seeds.get(0).scene
	player_passives = player.get_node("Passives")
	for passive in player_passives.get_children():
		if passive.name == "Potato":
			continue
		passives.add_child(passive.duplicate())
	player.dashed.connect(explode)

func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemies"):
		explode()

func explode():
	if _has_exploded:
		return
	_has_exploded = true
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = DAMAGE * damage_multiplier
	explosion.size = BLAST_RADIUS
	explosion.source = self
	explosion.modulate = Color("ce9e54")
	SfxDeconflicter.play(mild_explosion_SFX)
	visible = false
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	create_explosion.call_deferred(explosion)
	shoot_seed.call_deferred()
	if mild_explosion_SFX.playing:
		await mild_explosion_SFX.finished
	queue_free.call_deferred()

func create_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = self.global_position

func shoot_seed():
	if first_seed == null:
		return
	for i in number_of_shots:
		var seed_instance = first_seed.instantiate()
		seed_instance.transferred_damage_multiplier *= 1.5
		# split the directions of each shot equally
		weapon_direction = Vector2.UP.rotated(TAU / number_of_shots * i)
		seed_instance.desired_direction = weapon_direction
		seed_instance.previous_weapon = self
		seed_instance.initial_weapon = true
		seed_instance.slot_index = 0
		seed_instance.seed_slot_number = PlayerSeeds.seed_indices[0]
		get_tree().current_scene.add_child(seed_instance)
		weapon_fired.emit(seed_instance)
		seed_instance.global_position = global_position + seed_instance.desired_direction * 3

func _on_lifetime_timeout():
	explode()
