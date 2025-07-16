extends "res://Scripts/Seeds/seed_template.gd"

@onready var fire_delay = $"Fire Delay"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

var letters = {
	"e": load("res://Scenes/Seeds/Effects/e.tscn"),
	"d": load("res://Scenes/Seeds/Effects/d.tscn"),
	"o": load("res://Scenes/Seeds/Effects/o.tscn"),
	"v": load("res://Scenes/Seeds/Effects/v.tscn"),
	"i": load("res://Scenes/Seeds/Effects/i.tscn"),
	"a": load("res://Scenes/Seeds/Effects/a.tscn")
}

var current_letter: int
var collided_enemy: bool
var letter_list = ["e", "e", "d", "o", "v", "i", "a"]
var origin_point
var first_collision_ignored: bool

func _ready():
	super._ready()
	fire_delay.start(0.1)
	first_collision_ignored = ignore_first_collision
	await get_tree().physics_frame
	origin_point = global_position

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
		collided_enemy = true
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	shoot_next_weapon()
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.bubble_pop_2)
	explode()
	destroy()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	weapon_direction = direction
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, collided_enemy)

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.25 * SIZE
	splash.source = self
	splash.modulate = Color("99e550")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = global_position

func _on_fire_delay_timeout():
	var dir = desired_direction
	if current_letter >= letter_list.size():
		return
	if is_instance_valid(previous_weapon):
		dir = previous_weapon.weapon_direction
		origin_point = previous_weapon.global_position
	if dir.is_equal_approx(Vector2.ZERO):
		dir = direction
	var weapon = letters[letter_list[current_letter]].instantiate()
	shoot_current_seed(weapon, dir, origin_point)
	seed_spawned.emit(weapon)

func shoot_current_seed(instantiated_weapon, _desired_direction = desired_direction, pos = global_position):
	instantiated_weapon.current_letter = current_letter + 1
	instantiated_weapon.shader = shader
	instantiated_weapon.collisions = collisions
	instantiated_weapon.source = source
	instantiated_weapon.previous_weapon = previous_weapon
	instantiated_weapon.target_group = target_group
	instantiated_weapon.desired_direction = _desired_direction
	instantiated_weapon.slot_index = slot_index
	instantiated_weapon.seed_slot_number = seed_slot_number
	instantiated_weapon.set_next_seed_slot_number = set_next_seed_slot_number
	instantiated_weapon.set_next_seed_slot_index = set_next_seed_slot_index
	instantiated_weapon.ignore_first_collision = first_collision_ignored
	instantiated_weapon.transferred_speed_multiplier *= transferred_speed_multiplier
	instantiated_weapon.transferred_range_multiplier *= transferred_range_multiplier
	instantiated_weapon.transferred_size_multiplier *= transferred_size_multiplier
	instantiated_weapon.transferred_damage_multiplier *= transferred_damage_multiplier
	instantiated_weapon.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
	instantiated_weapon.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
	instantiated_weapon.modulate = modulate
	weapon_direction = _desired_direction
	get_tree().current_scene.add_child.call_deferred(instantiated_weapon)
	instantiated_weapon.global_position = pos
	weapon_fired.emit(instantiated_weapon)
