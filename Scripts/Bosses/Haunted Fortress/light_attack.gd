extends Node2D

@onready var warning_circle = $"Warning Circle"
@onready var beam = $Beam
@onready var hitbox = $Hitbox
@onready var damage_buffer = $"Damage Buffer"
@onready var attack_delay = $"Attack Delay"
@onready var fade_timer = $"Fade Timer"
@onready var player := $"../Player"
@onready var light_beam_SFX = $LightBeam

var is_in_area := false
var fade_timer_mult
var fade := false
var played := false
var damage = 1

func _ready():
	fade_timer_mult = 1/fade_timer.wait_time
	$Beam.visible = false

func _physics_process(delta):
	if is_in_area and damage_buffer.is_stopped():
		player._player_stats.take_damage(self)
		damage_buffer.start()
	if attack_delay.is_stopped() and not played:
		played = true
		SfxDeconflicter.play(light_beam_SFX)
		$Beam.visible = true
		$Beam.play("default")
		$Hitbox.set_collision_layer(16)
		$Hitbox.set_collision_mask(2)
		$"Warning Circle".visible = false
	if fade:
		$Beam.modulate.a = fade_timer_mult * fade_timer.time_left
		if $Beam.modulate.a == 0: # when the light attack beam is fully invisible, delete the node
			queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		is_in_area = true

func _on_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func _on_beam_animation_finished():
	fade_timer.start()

func _on_fade_timer_timeout():
	fade = true
