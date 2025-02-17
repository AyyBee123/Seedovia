extends "res://Scripts/Passives/Classes/passive_chance.gd"

var source
var first_inv_seed

@onready var timer = $Timer

func _ready():
	source = get_parent().get_parent()
	chance = 0.05
	super._ready()
	source.weapon_fired.connect(transfer_passive)

func _physics_process(delta):
	if timer.is_stopped():
		if source.is_in_group("Seed"):
			chance_to_trigger(source)
			timer.start()

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null or weapon.is_in_group("Weapon Effect"):
		return
	# make a new clockwork passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(self.duplicate())

func trigger(weapon = null):
	if source.is_in_group("Staff of Growth Seed"):
		return
	first_inv_seed = PlayerInventory.inventory.get(0)
	if first_inv_seed == null:
		return
	if first_inv_seed.category != "SEED":
		return
	var seed_instance = first_inv_seed.scene.instantiate()
	seed_instance.previous_weapon = weapon
	seed_instance.desired_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	seed_instance.seed_slot_number = 3 # to not trigger any slot-specific effects
	seed_instance.slot_index = 2 # to not fire any other seeds
	seed_instance.transferred_speed_multiplier = weapon.transferred_speed_multiplier
	seed_instance.transferred_range_multiplier = weapon.transferred_range_multiplier
	seed_instance.transferred_size_multiplier = weapon.transferred_size_multiplier
	seed_instance.transferred_damage_multiplier = weapon.transferred_damage_multiplier
	seed_instance.transferred_blast_radius_multiplier = weapon.transferred_blast_radius_multiplier
	seed_instance.transferred_fire_rate_multiplier = weapon.transferred_fire_rate_multiplier
	seed_instance.add_to_group("Staff of Growth Seed")
	get_tree().current_scene.add_child.call_deferred(seed_instance)
	weapon.weapon_fired.emit(seed_instance)
	seed_instance.global_position = weapon.next_weapon_pos
