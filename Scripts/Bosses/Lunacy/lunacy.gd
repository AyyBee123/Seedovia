extends "res://Scripts/Bosses/boss.gd"

var lunacy_projectile = preload("res://Scenes/Enemies/Weapons/Lunacy Projectile.tscn")

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
