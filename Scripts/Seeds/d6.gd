extends "res://Scripts/Seeds/seed_template.gd"

const EXPLOSION = preload("res://Scenes/Passives/Effects/Explosion.tscn")

var clockwise_rotation: bool
var dice_value: int

@onready var randomize_interval = $"Randomize Interval"
@onready var resource_preloader = $ResourcePreloader
@onready var dice_roll_SFX = $DiceRoll

func _ready():
	super._ready()
	randomize_interval.start()
	SfxDeconflicter.play(dice_roll_SFX)
	clockwise_rotation = randf() < 0.5

func _physics_process(delta):
	super._physics_process(delta)
	spin()
	randomize_value()

func update_position(delta):
	current_velocity = direction * player._player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta

func spin():
	if clockwise_rotation:
		rotation_degrees += 2
	else:
		rotation_degrees -= 2

func randomize_value():
	if randomize_interval.is_stopped():
		var current_dice_value = dice_value
		while dice_value == current_dice_value:
			dice_value = randi_range(1, 6)
		match dice_value:
			1:
				if randi_range(0, 99) == 0: # 1 in 100 chance to replace the 1-side with a familiar face
					texture = resource_preloader.get_resource("D6 (I)")
				else:
					texture = resource_preloader.get_resource("D6 (1)")
			2:
				texture = resource_preloader.get_resource("D6 (2)")
			3:
				texture = resource_preloader.get_resource("D6 (3)")
			4:
				texture = resource_preloader.get_resource("D6 (4)")
			5:
				texture = resource_preloader.get_resource("D6 (5)")
			6:
				texture = resource_preloader.get_resource("D6 (6)")
		SfxDeconflicter.play(dice_roll_SFX)
		randomize_interval.start()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(player._player_stats.get_stat("Weapon_Damage") * damage_multiplier * get_dice_damage_multiplier())
	var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 \
			else PlayerSeeds.seeds[slot_index + 1]
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.bubble_pop_2)
	shoot_next_weapon()
	explode()
	queue_free.call_deferred()

func shoot_next_weapon():
	for i in dice_value:
		weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		super.shoot_next_weapon()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= player._player_stats.get_stat("Weapon_Range") * range_multiplier:
		attempted_fire.emit()
		for i in range(seed_slots.size()):
			var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 \
					else PlayerSeeds.seeds[slot_index + 1]
			shoot_next_weapon()
			break
		queue_free.call_deferred()

func get_dice_damage_multiplier() -> float:
	var dice_damage: float
	match dice_value:
		1:
			dice_damage = 0.25
		2:
			dice_damage = 0.5
		3:
			dice_damage = 0.75
		4:
			dice_damage = 1
		5:
			dice_damage = 1.35
		6:
			dice_damage = 2.0
	return dice_damage

func explode():
	var explosion = EXPLOSION.instantiate()
	explosion.damage = 0
	explosion.size = 0.2
	explosion.source = self
	explosion.modulate = Color("611e30")
	explosion.is_vanity = true
	call_deferred("create_child", explosion)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
