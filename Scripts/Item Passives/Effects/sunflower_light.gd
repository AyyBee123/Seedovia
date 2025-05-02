extends Sprite2D

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall

const CHANCE_TO_SHOOT_SEED = 0.1

var damage: float
var damage_multiplier: float = 0.5
var tick_rate: float = 0.25
var size: float
var size_multiplier: float = 5
var second_seed
var enemies_in_area: Array
var tick_timers: Array
var weapon_direction
var player

func _ready():
	visible = false
	player = get_parent().get_parent()
	damage = 10
	size = 1.5
	has_collided.connect(shoot_seed)

func _physics_process(delta):
	global_position = player.global_position
	visible = true
	second_seed = null if PlayerInventory.seeds.get(1) == null else PlayerInventory.seeds.get(1).scene
	scale = Vector2.ONE * size * size_multiplier
	
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(damage * damage_multiplier)
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
				tick_timers[i].start(tick_rate)

func shoot_seed(enemy):
	if second_seed == null:
		return
	if randf() <= CHANCE_TO_SHOOT_SEED:
		var seed_instance = second_seed.instantiate()
		seed_instance.desired_direction = global_position.direction_to(enemy.get_parent().global_position)
		seed_instance.seed_slot_number = 1
		if PlayerInventory.seeds.has(0):
			seed_instance.slot_index = 1
		else:
			seed_instance.slot_index = 0
		seed_instance.source = self
		seed_instance.previous_weapon = self
		get_tree().current_scene.add_child(seed_instance)
		player.weapon_fired.emit(seed_instance)
		seed_instance.global_position = global_position + seed_instance.desired_direction * 3

func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate
			timer.one_shot = true
			tick_timers.append(timer)

func _on_area_2d_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)
