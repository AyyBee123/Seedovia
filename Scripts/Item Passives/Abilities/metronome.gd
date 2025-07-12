extends "res://Scripts/Passives/Classes/passive_chance.gd"

const SPREAD = PI/6

var source
var seed

func _ready():
	source = get_parent().get_parent()
	chance = 0.03
	super._ready()
	source.weapon_fired.connect(transfer_passive)
	source.weapon_fired.connect(chance_to_trigger)

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null or weapon.is_in_group("Weapon Effect"):
		return
	# make a new clockwork passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(self.duplicate())

func trigger(weapon = null):
	if source.is_in_group("Metronome Seed"):
		return
	if not source.is_in_group("Seed"):
		return
	seed = Pool.seed_list.pick_random()
	var res = ResourceLoader.load(seed)
	if res.category != "SEED": # just in case
		return
	if not res.unlocked: # if the seed is not unlocked yet, recur the function
		trigger(weapon)
		return
	var seed_instance = res.scene.instantiate()
	seed_instance.previous_weapon = source
	seed_instance.desired_direction = source.weapon_direction.rotated(randf_range(-SPREAD, SPREAD))
	if seed_instance.desired_direction.is_equal_approx(Vector2.ZERO):
		seed_instance.desired_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	seed_instance.seed_slot_number = 3 # to not trigger any slot-specific effects
	seed_instance.slot_index = 3 # to not fire any other seeds
	seed_instance.add_to_group("Metronome Seed")
	get_tree().current_scene.add_child.call_deferred(seed_instance)
	source.weapon_fired.emit(seed_instance)
	await get_tree().physics_frame # in case the seed still needs to set its position
	seed_instance.global_position = source.next_weapon_pos
