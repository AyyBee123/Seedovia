extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var lifetime = $Lifetime
@onready var fire_rate = $"Fire Rate"
@onready var animated_sprite_2d = $AnimatedSprite2D

var time_to_live: float = 5
var blossom_fire_rate_multiplier: float = 0.5
var hit_wall := false

func _ready():
	super._ready()
	deceleration.start()
	if target_group == "Players":
		var blossom = load("res://Scenes/Enemies/Cursed Blossom.tscn").instantiate()
		blossom.visible = false
		get_tree().current_scene.add_child(blossom)
		await get_tree().physics_frame
		blossom.global_position = global_position
		blossom.visible = true
		destroy()

func _physics_process(delta):
	super._physics_process(delta)
	if fire_rate.is_stopped() and get_nearest_enemy() != null and deceleration.is_stopped():
		shoot_next_weapon()

func update_position(delta):
	if not hit_wall:
		current_velocity = direction * SPEED * deceleration.time_left
		position += current_velocity * delta

func travelled_distance():
	pass

func _collide(body):
	pass

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	if global_position.distance_to(get_nearest_enemy().global_position) > get_next_weapon().instantiate().RANGE:
		return
	play_animation()
	var weapon_instance = get_next_weapon().instantiate()
	weapon_direction = global_position.direction_to(get_nearest_enemy().global_position)
	set_weapon_properties(weapon_instance, weapon_direction)

func initialize_location(weapon):
	super.initialize_location(weapon)
	fire_rate.start(1.0 / (blossom_fire_rate_multiplier * weapon.FIRE_RATE))

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var nearest_enemy = null
	var nearest_distance = null
	for i in enemies.size():
		if nearest_enemy == null:
			nearest_enemy = enemies[i]
			nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
		else:
			if nearest_distance > enemies[i].global_position.distance_squared_to(global_position):
				nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
				nearest_enemy = enemies[i]
	return nearest_enemy

func _on_lifetime_timeout():
	destroy()

func play_animation():
	animated_sprite_2d.play("Shoot")

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("Idle")

func _on_deceleration_timeout():
	lifetime.start(time_to_live)
