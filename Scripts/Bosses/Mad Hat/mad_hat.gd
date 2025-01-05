extends "res://Scripts/Bosses/boss.gd"

@onready var _state_machine = $StateMachine
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_polygon_2d = $"Enemy Hitbox/CollisionPolygon2D"

const MAD_HAT_HAND = preload("res://Scenes/Bosses/Mad Hat Hand.tscn")
const MAD_FPS_CAP = 1.0 / 20.0

var tween_x
var tween_y
var mad_fps: float
var last_mad_frame: int
var mad_fps_cap: float = 1.0 / 20.0 # 20 fps

func _ready():
	super._ready()
	for i in [-1, 1]:
		var hand = MAD_HAT_HAND.instantiate()
		hand.mad_hat = self
		hand.pos = Vector2(250 * i, 250)
		if i == 1:
			hand.get_node("AnimatedSprite2D").flip_h = true
			hand.get_node("AnimatedSprite2D").position.x = -10
		get_tree().current_scene.add_child.call_deferred(hand)

func idle():
	_enemy_stats.damage = 0

func mad():
	mad_fps += get_physics_process_delta_time()
	if mad_fps >= mad_fps_cap:
		var rnd = randi_range(0, 6)
		while last_mad_frame == rnd: # keep looping until both numbers are not equal to each other
			rnd = randi_range(0, 6)
		animated_sprite_2d.frame = rnd
		last_mad_frame = rnd
		mad_fps = 0

func handpocalypse():
	pass

func hats():
	pass

func slam():
	pass

func charge():
	pass

func move_eratically():
	tween_x = get_tree().create_tween().set_loops(2)
	tween_y = get_tree().create_tween().set_loops(2)
	
	tween_x.set_trans(Tween.TRANS_SINE)
	tween_y.set_trans(Tween.TRANS_SINE)
	
	tween_x.tween_property(self, "position:x", 350, 1.25).set_ease(Tween.EASE_OUT_IN)
	tween_y.tween_property(self, "position:y", 250, 1.25)
	
	tween_x.tween_property(self, "position:x", 730, 0.5).set_ease(Tween.EASE_OUT)
	tween_x.tween_property(self, "position:x", 350, 0.5).set_ease(Tween.EASE_IN)
	tween_y.tween_property(self, "position:y", -250, 1)
	
	tween_x.tween_property(self, "position:x", -350, 1.25).set_ease(Tween.EASE_OUT_IN)
	tween_y.tween_property(self, "position:y", 250, 1.25)
	
	tween_x.tween_property(self, "position:x", -730, 0.5).set_ease(Tween.EASE_OUT)
	tween_x.tween_property(self, "position:x", -350, 0.5).set_ease(Tween.EASE_IN)
	tween_y.tween_property(self, "position:y", -250, 1)
	
	tween_x.finished.connect(move_back)

func kill_tween():
	if tween_x:
		tween_x.kill()
	
	if tween_y:
		tween_y.kill()
	
	_state_machine.set_state(_state_machine.states.idle)

func move_back():
	tween_x = get_tree().create_tween()
	tween_y = get_tree().create_tween()
	
	tween_x.set_trans(Tween.TRANS_SINE)
	tween_y.set_trans(Tween.TRANS_SINE)
	
	
	tween_x.tween_property(self, "position:x", 0, 0.75).set_ease(Tween.EASE_IN_OUT)
	tween_x.parallel().tween_method(madness, MAD_FPS_CAP, 1.0 / 5.0, 0.75)
	tween_y.tween_property(self, "position:y", -200, 0.75).set_ease(Tween.EASE_OUT)
	
	tween_x.finished.connect(kill_tween)

func madness(amount):
	mad_fps_cap = amount
