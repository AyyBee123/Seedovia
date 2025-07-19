extends Node

const DOOMED = preload("res://Scenes/Passives/Effects/Doomed.tscn")

var source
var damage: float

func _ready():
	source = get_parent().get_parent()

func _physics_process(delta):
	# add the "Doomed" node to all enemies if they don't have it
	var enemies = Targets.get_enemies()
	for enemy in enemies:
		if not enemy.get_node_or_null("Doomed"):
			var doomed = DOOMED.instantiate()
			enemy.add_child(doomed)
