extends "res://Scripts/Enemies/enemy.gd"

@onready var boss_health_bar = $"Health Bar/Health Bar"
@onready var boss_name = $"Health Bar/Boss Name"

func _ready():
	# no super._ready() call because the enemy script calls a health bar, which the boss scene doesn't have
	_enemy_stats = _enemy_stats.duplicate()
	_enemy_stats.initialize_stats(_enemy_stats)
	_enemy_stats.set_health(_enemy_stats.max_health)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.health_depleted.connect(die)
	_enemy_stats.spawn_damage_number.connect(spawn_damage_number)
	_enemy_stats.change_color.connect(change_color)
	boss_name.text = self.name
	boss_health_bar.init_health(_enemy_stats.max_health)

func _physics_process(delta):
	super._physics_process(delta)
	if accumulated_timer_delay.is_stopped():
		accumulated_damage_text.visible = false
		accumulated_damage = 0
	else:
		accumulated_damage_text.visible = true

func update_health(new_health):
	boss_health_bar.health = new_health

func spawn_damage_number(damage: float):
	accumulated_damage += damage
	accumulated_damage_text.text = "[right]" + str(int(round(accumulated_damage)))
	accumulated_timer_delay.start()
