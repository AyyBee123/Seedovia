extends "res://Scripts/Enemies/enemy.gd"

@onready var boss_health_bar = $"Boss Health/Health Bar"
@onready var boss_name = $"Boss Health/Boss Name"


func _ready():
	super._ready()
	boss_name.text = self.name
	boss_health_bar.init_health(_enemy_stats.max_health)

func update_health(new_health):
	boss_health_bar.health = new_health
