extends "res://Scripts/Seeds/seed_template.gd"

const NUMBER_OF_SEEDS = 3

var random_rotation: float

func _ready():
	randomize()
	random_rotation = randf_range(0, TAU)
	super._ready()
	scale = Vector2.ONE * (SIZE + BLAST_RADIUS) / 2
	$AnimatedSprite2D.play("boom")
	
	SfxDeconflicter.play(Game.audio_manager._8_bit_boom)
	SfxDeconflicter.play(Game.audio_manager.pome_mild_explosion_3)
	
	for i in NUMBER_OF_SEEDS:
		weapon_direction = Vector2.UP.rotated(TAU / NUMBER_OF_SEEDS * i).rotated(random_rotation)
		shoot_next_weapon()

func _on_animated_sprite_2d_animation_finished():
	destroy()

func travelled_distance():
	pass

func _on_area_2d_area_entered(area):
	has_collided.emit(area)
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(DAMAGE)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Players"):
		body._player_stats.take_damage(1)
