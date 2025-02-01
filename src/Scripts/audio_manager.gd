extends Node

@onready var music_player = $MusicPlayer
@onready var sfx_player = $SFXPlayer

# Dictionary of sound effects
var sfx_library = {
	"back_button_click": preload("res://Assets/Audio/SFX/back_style_2_001.ogg"),
	"confirm_button_click": preload("res://Assets/Audio/SFX/confirm_style_2_001.ogg"),
	"confirm_echo_button_click": preload("res://Assets/Audio/SFX/confirm_style_2_echo_001.ogg"),
	"error_button_click": preload("res://Assets/Audio/SFX/error_style_2_001.ogg"),
	"win_sound": preload("res://Assets/Audio/SFX/magic_003.wav"),
	"lose_sound": preload("res://Assets/Audio/SFX/explosion_02.wav")
}

var dice_sfx_library = {
	"dice_roll_1": preload("res://Assets/Audio/SFX/DiceRolls/dice-1.wav"),
	"dice_roll_2": preload("res://Assets/Audio/SFX/DiceRolls/dice-2.wav"),
	"dice_roll_3": preload("res://Assets/Audio/SFX/DiceRolls/dice-3.wav"),
	"dice_roll_4": preload("res://Assets/Audio/SFX/DiceRolls/dice-4.wav"),
	"dice_roll_5": preload("res://Assets/Audio/SFX/DiceRolls/dice-5.wav"),
	"dice_roll_6": preload("res://Assets/Audio/SFX/DiceRolls/dice-6.wav"),
	"dice_roll_7": preload("res://Assets/Audio/SFX/DiceRolls/dice-7.wav"),
	"dice_roll_8": preload("res://Assets/Audio/SFX/DiceRolls/dice-8.wav"),
	"dice_roll_9": preload("res://Assets/Audio/SFX/DiceRolls/dice-9.wav"),
	"dice_roll_10": preload("res://Assets/Audio/SFX/DiceRolls/dice-10.wav"),
	"dice_roll_11": preload("res://Assets/Audio/SFX/DiceRolls/dice-11.wav"),
	"dice_roll_12": preload("res://Assets/Audio/SFX/DiceRolls/dice-12.wav"),
	"dice_roll_13": preload("res://Assets/Audio/SFX/DiceRolls/dice-13.wav"),
	"dice_roll_14": preload("res://Assets/Audio/SFX/DiceRolls/dice-14.wav"),
	"dice_roll_15": preload("res://Assets/Audio/SFX/DiceRolls/dice-15.wav"),
	"dice_roll_16": preload("res://Assets/Audio/SFX/DiceRolls/dice-16.wav"),
	"dice_roll_17": preload("res://Assets/Audio/SFX/DiceRolls/dice-17.wav"),
	"dice_roll_18": preload("res://Assets/Audio/SFX/DiceRolls/dice-18.wav"),
	"dice_roll_19": preload("res://Assets/Audio/SFX/DiceRolls/dice-19.wav"),
	"dice_roll_20": preload("res://Assets/Audio/SFX/DiceRolls/dice-20.wav"),
	"dice_roll_21": preload("res://Assets/Audio/SFX/DiceRolls/dice-21.wav"),
	"dice_roll_22": preload("res://Assets/Audio/SFX/DiceRolls/dice-22.wav"),
	"dice_roll_23": preload("res://Assets/Audio/SFX/DiceRolls/dice-23.wav"),
	"dice_roll_24": preload("res://Assets/Audio/SFX/DiceRolls/dice-24.wav"),
	"dice_roll_25": preload("res://Assets/Audio/SFX/DiceRolls/dice-25.wav"),
	"dice_roll_26": preload("res://Assets/Audio/SFX/DiceRolls/dice-26.wav"),
	"dice_roll_27": preload("res://Assets/Audio/SFX/DiceRolls/dice-27.wav"),
	"dice_roll_28": preload("res://Assets/Audio/SFX/DiceRolls/dice-28.wav"),
	"dice_roll_29": preload("res://Assets/Audio/SFX/DiceRolls/dice-29.wav"),
}

# Dictionary of background music tracks
var music_library = {
	"main_menu": preload("res://Assets/Audio/Music/AJP 3 Constellate impromptu only 0m18s.mp3"),
	"gameplay": preload("res://Assets/Audio/Music/AJ4 Bucket of Stardust 0m18s.mp3"),
	"gameplay_tense": preload("res://Assets/Audio/Music/AJ4 Bucket of Stardust 0m18s.mp3")
	#Tense music can be changed to be be just a sound effect
}

func _ready():
	# Set default volume levels
	set_music_volume(0.2)
	set_sfx_volume(0.4)
	AudioManager.play_music("main_menu")
	connect_buttons()

func connect_buttons() -> void:
	var confirm_buttons: Array = get_tree().get_nodes_in_group("ConfirmButtons")
	for inst in confirm_buttons:
		inst.connect("pressed", self.on_confirm_button_pressed)
	
	var back_buttons: Array = get_tree().get_nodes_in_group("BackButtons")
	for inst in back_buttons:
		inst.connect("pressed", self.on_back_button_pressed)

func on_confirm_button_pressed()->void:
	play_sfx("confirm_button_click")

func on_back_button_pressed()->void:
	play_sfx("back_button_click")

func play_music(track_name: String, loop: bool = true):
	if track_name in music_library:
		music_player.stream = music_library[track_name]
		print("Music Audio Playing: ", track_name)
		music_player.play()
		#music_player.loop = loop
	else:
		push_error("Music track not found: " + track_name)

func stop_music():
	music_player.stop()

func play_sfx(sfx_name: String):
	if sfx_name in sfx_library:
		sfx_player.stream = sfx_library[sfx_name]
		print("SFX Audio Playing: ", sfx_name)
		sfx_player.play()
	else:
		push_error("SFX not found: " + sfx_name)

func play_dice_sfx():
	#Change to use collisions to emit sound or additive
	var dice_sfx_keys = dice_sfx_library.keys()  # Get the list of dice sound keys
	var random_key = dice_sfx_keys[randi() % dice_sfx_keys.size()]  # Pick a random key
	print("Dice Audio Playing: ", random_key)
	sfx_player.stream = dice_sfx_library[random_key]  # Assign the audio stream
	sfx_player.play()  # Play the sound

func set_music_volume(volume: float): #float 0 to 1
	music_player.volume_db = linear_to_db(volume)  

func set_sfx_volume(volume: float): #float 0 to 1
	sfx_player.volume_db = linear_to_db(volume)  
