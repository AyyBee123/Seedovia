extends Control

@onready var player = get_parent()
@onready var coins = %Amount.text
@onready var max_health = %"Max Health UI"
@onready var current_health = %"Current Health UI"

var empty_heart = preload("res://Scenes/UI/empty_heart.tscn")
var filled_heart = preload("res://Scenes/UI/filled_heart.tscn")

func _ready():
	set_health()
	set_coins()

func _physics_process(delta):
	if player._player_stats.get_stat("Max_Health") != max_health.get_child_count() \
			or player._player_stats.health != current_health.get_child_count():
		set_health()
	if PlayerCharacter.coins != int(%Amount.text):
		set_coins()

func set_health():
	# remove all hearts in the health ui
	for i in max_health.get_children(): # remove empty heart containers
		max_health.remove_child(i)
		i.queue_free()
	for i in current_health.get_children(): # remove filled heart containers
		current_health.remove_child(i)
		i.queue_free()

	# add hearts in the hearts ui
	for i in range(player._player_stats.get_stat("Max_Health")): # add empty heart containers
		var heart_instance = empty_heart.instantiate()
		max_health.add_child(heart_instance)
	for i in range(player._player_stats.health): # add filled heart containers
		var heart_instance = filled_heart.instantiate()
		current_health.add_child(heart_instance)

func set_coins():
	%Amount.text = str(PlayerCharacter.coins) # display number of coins player has
