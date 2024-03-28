extends "res://Scripts/Enemies/enemy.gd"

@onready var boss_health_bar = $"Boss Health/Health Bar"
@onready var boss_name = $"Boss Health/Boss Name"


func _ready():
	_enemy_stats = _enemy_stats.duplicate()
	_enemy_stats.initialize_stats(_enemy_stats)
	_enemy_stats.set_health(_enemy_stats.max_health)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.health_depleted.connect(die)
	_enemy_stats.spawn_damage_number.connect(spawn_damage_number)
	boss_name.text = self.name
	boss_health_bar.init_health(_enemy_stats.max_health)

func update_health(new_health):
	boss_health_bar.health = new_health
