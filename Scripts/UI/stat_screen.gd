extends CanvasLayer

const PASSIVE_CONTAINER = preload("res://Scenes/UI/Passive Container.tscn")

@onready var speed_info = %SpeedInfo
@onready var dash_rate_info = %DashRateInfo
@onready var dash_distance_info = %DashDistanceInfo
@onready var dash_invul_info = %DashInvulInfo

@onready var damage_info = %DamageInfo
@onready var damage_info_2 = %DamageInfo2

@onready var fire_rate_info = %FireRateInfo
@onready var fire_rate_info_2 = %FireRateInfo2

@onready var range_info = %RangeInfo
@onready var range_info_2 = %RangeInfo2

@onready var proj_speed_info = %ProjSpeedInfo
@onready var proj_speed_info_2 = %ProjSpeedInfo2

@onready var blast_radius_info = %BlastRadiusInfo
@onready var blast_radius_info_2 = %BlastRadiusInfo2

const scroll_speed = 250

var player
var number_of_passives: int
var scroll_value = 0
var up_held: bool
var down_held: bool

func _ready():
	visible = false
	player = Targets.get_player()

func _physics_process(delta):
	speed_info.text = str(player._player_stats.get_stat("Speed"))
	dash_rate_info.text = str(player._player_stats.get_stat("Dash_Rate"))
	dash_distance_info.text = str(player._player_stats.get_stat("Dash_Distance"))
	dash_invul_info.text = str(player._player_stats.get_stat("Dash_Invulnerability"))
	
	damage_info.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Damage"]["+"] * 100))
	damage_info_2.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Damage"]["x"]))
	
	fire_rate_info.text = "[right]" + str(roundi(player._player_stats.stats["Fire_Rate"]["+"] * 100))
	fire_rate_info_2.text = "[right]" + str(roundi(player._player_stats.stats["Fire_Rate"]["x"]))
	
	range_info.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Range"]["+"] * 100))
	range_info_2.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Range"]["x"]))
	
	proj_speed_info.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Speed"]["+"] * 100))
	proj_speed_info_2.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Speed"]["x"]))
	
	blast_radius_info.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Blast_Radius"]["+"] * 100))
	blast_radius_info_2.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Blast_Radius"]["x"]))
	
	if visible:
		if up_held:
			%ScrollContainer.set_v_scroll(round(%ScrollContainer.scroll_vertical - scroll_speed * delta))
		elif down_held:
			%ScrollContainer.set_v_scroll(round(%ScrollContainer.scroll_vertical + scroll_speed * delta))
	
	if Input.is_action_just_pressed("stat_sheet"):
		# toggle stat sheet UI to open/close
		visible = not visible
		
		if not visible:
			up_held = false
			down_held = false
		
		if visible:
			for i in %Passives.get_children():
				i.queue_free()
			for p in PlayerPassives.passive_list:
				var container = PASSIVE_CONTAINER.instantiate()
				container.get_node("%Image").texture = p.sprite
				container.get_node("%Description").text = p.description
				container.get_node("%Name").text = p.passive_name
				%Passives.add_child(container)
			%ScrollContainer.set_v_scroll(0)

func _input(event):
	if Input.is_action_just_pressed("stat_sheet_up"):
		up_held = true
	if Input.is_action_just_released("stat_sheet_up"):
		up_held = false
	
	if Input.is_action_just_pressed("stat_sheet_down"):
		down_held = true
	if Input.is_action_just_released("stat_sheet_down"):
		down_held = false
