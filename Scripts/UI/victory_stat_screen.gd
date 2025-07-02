extends MarginContainer

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
	player = LevelList.player.instantiate()
	player.visible = false
	player.get_node("Player Health/CanvasLayer").visible = false
	add_child(player)
	player.global_position = Vector2(0, 330)
	player.process_mode = Node.PROCESS_MODE_DISABLED

func _physics_process(delta):
	speed_info.text = str(roundi(player._player_stats.get_stat("Speed")))
	dash_rate_info.text = str(roundi(player._player_stats.get_stat("Dash_Rate")))
	dash_distance_info.text = str(roundi(player._player_stats.get_stat("Dash_Distance")))
	dash_invul_info.text = str(roundi(player._player_stats.get_stat("Dash_Invulnerability")))
	
	damage_info.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Damage"]["+"] * 100))
	damage_info_2.text = "[right]" + str(snapped(player._player_stats.stats["Weapon_Damage"]["x"], 0.01))
	
	fire_rate_info.text = "[right]" + str(roundi(player._player_stats.stats["Fire_Rate"]["+"] * 100))
	fire_rate_info_2.text = "[right]" + str(snapped(player._player_stats.stats["Fire_Rate"]["x"], 0.01))
	
	range_info.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Range"]["+"] * 100))
	range_info_2.text = "[right]" + str(snapped(player._player_stats.stats["Weapon_Range"]["x"], 0.01))
	
	proj_speed_info.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Speed"]["+"] * 100))
	proj_speed_info_2.text = "[right]" + str(snapped(player._player_stats.stats["Weapon_Speed"]["x"], 0.01))
	
	blast_radius_info.text = "[right]" + str(roundi(player._player_stats.stats["Weapon_Blast_Radius"]["+"] * 100))
	blast_radius_info_2.text = "[right]" + str(snapped(player._player_stats.stats["Weapon_Blast_Radius"]["x"], 0.01))
