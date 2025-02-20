extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var audio_player = AudioManager
@onready var hidden = false
#var drinking_interval = 5.0  # Seconds between drinks

func _ready():
	play_idle()
	#start_drinking_timer()

func play_idle():
	animation_player.play("Idle")

func play_drink():
	animation_player.play("Use_Item") #Drink
	AudioManager.play_ambience("drink_sip")

func start_drinking_timer():
	if hidden:
		return
	var random_interval = randf_range(10.0, 25.0)  # Randomize between 4-7 sec
	await get_tree().create_timer(random_interval).timeout
	play_drink()
	await animation_player.animation_finished
	start_drinking_timer()

func set_hidden(state: bool):
	hidden = state
	if !hidden:
		start_drinking_timer()
