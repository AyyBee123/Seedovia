extends "res://Scripts/Passives/Classes/passive_chance.gd"

var damage: float # damage of each burn tick
var source

@onready var resource_preloader = $ResourcePreloader

func _ready():
	source = get_parent().get_parent()
	chance = 1
	if source.is_in_group("Players"):
		source.weapon_fired.connect(chance_to_trigger)
	super._ready()

func trigger(weapon = null):
	var poison_aura = resource_preloader.get_resource("Poison Aura").instantiate()
	weapon.weapon_fired.connect(trigger)
	poison_aura.damage = player._player_stats.get_stat("Weapon_Damage") * weapon.damage_multiplier
	poison_aura.damage_multiplier = 0.2
	poison_aura.radius_multiplier = player._player_stats.get_stat("Weapon_Size")
	poison_aura.weapon = weapon
	weapon.add_child.call_deferred(poison_aura)
	poison_aura.position = Vector2.ZERO
	transfer_passive(weapon)

func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	weapon.get_node("Passives").add_child(self.duplicate())
