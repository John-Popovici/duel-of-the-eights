extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var audio_player = AudioManager

#var drinking_interval = 5.0  # Seconds between drinks

func _ready():
	play_idle()
	start_drinking_timer()

func play_idle():
	animation_player.play("Idle")

func play_toast():
	animation_player.play("Spellcast_Raise") #Drink
	#AudioManager.play_ambience("drink_sip")

func start_drinking_timer():
	var random_interval = randf_range(7.0, 15.0)  # Randomize between 4-7 sec
	await get_tree().create_timer(random_interval).timeout
	play_toast()
	await animation_player.animation_finished
	start_drinking_timer()
