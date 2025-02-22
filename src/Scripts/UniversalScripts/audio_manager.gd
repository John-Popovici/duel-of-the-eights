extends Node

@onready var music_player = $MusicPlayer
@onready var sfx_player = $SFXPlayer
@onready var ambience_player = $AmbiencePlayer

# Dictionary of sound effects
var sfx_library = {
	"back_button_click": preload("res://Assets/Audio/SFX/back_style_2_001.ogg"),
	"confirm_button_click": preload("res://Assets/Audio/SFX/confirm_style_2_001.ogg"),
	"confirm_echo_button_click": preload("res://Assets/Audio/SFX/confirm_style_2_echo_001.ogg"),
	"error_button_click": preload("res://Assets/Audio/SFX/error_style_2_001.ogg"),
	"win_sound": preload("res://Assets/Audio/SFX/magic_003.wav"),
	"lose_sound": preload("res://Assets/Audio/SFX/explosion_02.wav"),
	"switch_on": preload("res://Assets/Audio/SFX/switch_on.wav"),
	"switch_off": preload("res://Assets/Audio/SFX/switch_on.wav"),
	"slider_ended": preload("res://Assets/Audio/SFX/slider_ended.wav"),
	"Raise": preload("res://Assets/Audio/SFX/Raise.mp3"),
	"Fold": preload("res://Assets/Audio/SFX/Fold.mp3"),
	"Heartbeat": preload("res://Assets/Audio/SFX/heartbeat-3s.mp3")
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

var game_music_library = [
	["Spring_Flowers",preload("res://Assets/Audio/Music/Spring_Flowers.mp3")],
	["beautiful_piano_melody",preload("res://Assets/Audio/Music/beautiful_piano_melody.mp3")],
	["soft_background_piano",preload("res://Assets/Audio/Music/soft_background_piano.mp3")]
]

var ambience_library ={
	"tavern_background": preload("res://Assets/Audio/Ambience/tavern-ambience-with-openfire-effect-no-loops-86151.mp3"),
	"wind_background": preload("res://Assets/Audio/Ambience/soft-wind-trees-moving-ambience-22292.mp3"),
	"drink_sip": preload("res://Assets/Audio/Ambience/drink-sip-and-swallow-6974.mp3")
}

@export var musicVolume: float = 0.2
@export var ambienceVolume: float = 0.2
@export var sfxVolume: float = 0.4

func _ready():
	# Set default volume levels
	if GlobalSettings.profile_settings["music_volume"] != null:
		set_music_volume(float(GlobalSettings.profile_settings["music_volume"]/100))
	else:
		set_music_volume(self.musicVolume)
	if GlobalSettings.profile_settings["sfx_volume"] != null:
		set_sfx_volume(float(GlobalSettings.profile_settings["sfx_volume"]/100))
	else:
		set_sfx_volume(self.sfxVolume)
	if GlobalSettings.profile_settings["ambience_volume"] != null:
		set_ambience_volume(float(GlobalSettings.profile_settings["ambience_volume"]/100))
	else:
		set_ambience_volume(self.ambienceVolume)
	AudioManager.play_music("main_menu")
	AudioManager.play_ambience("tavern_background")
	AudioManager.play_ambience("wind_background")
	connect_buttons()

func connect_buttons() -> void:
	var confirm_buttons: Array = get_tree().get_nodes_in_group("ConfirmButtons")
	for inst in confirm_buttons:
		inst.connect("pressed", self.on_confirm_button_pressed)
	
	var back_buttons: Array = get_tree().get_nodes_in_group("BackButtons")
	for inst in back_buttons:
		inst.connect("pressed", self.on_back_button_pressed)
		
	var switch_buttons: Array = get_tree().get_nodes_in_group("SwitchButtons")
	for inst in switch_buttons:
		inst.connect("toggled", self.on_switch_button_toggled)
		
	var sliders: Array = get_tree().get_nodes_in_group("Sliders")
	for inst in sliders:
		inst.connect("drag_ended", self.on_slider_ended)

func on_confirm_button_pressed()->void:
	play_sfx("confirm_button_click")

func on_back_button_pressed()->void:
	play_sfx("back_button_click")

func on_switch_button_toggled(button_pressed: bool)->void:
	if button_pressed:
		play_sfx("switch_on")
	else:
		play_sfx("switch_off")
		
func on_slider_ended(value_changed)->void:
	play_sfx("slider_ended")

func play_music(track_name: String, loop: bool = true):
	if track_name in music_library:
		music_player.stream = music_library[track_name]
		Debugger.log(str("Music Audio Playing: ", track_name))
		music_player.play()
		#music_player.loop = loop
	else:
		Debugger.log_error(str("Music track not found: " + track_name))
		

func play_game_music(track_num: int, loop: bool = false):
	
	if track_num < game_music_library.size():
		music_player.stream = game_music_library[track_num][1]
		Debugger.log(str("Music Audio Playing: ", game_music_library[track_num][0]))
		
		music_player.play()
		
		music_player.finished.connect(_on_track_finished, track_num)
		
func _on_track_finished(track_num: int):
	track_num += 1
	if track_num < game_music_library.size():
		play_game_music(track_num)
	else:
		track_num = 0
		play_game_music(track_num)


func play_ambience(ambience_name: String):
	if ambience_name in ambience_library:
		ambience_player.stream = ambience_library[ambience_name]
		Debugger.log(str("Ambience Audio Playing: ", ambience_name))
		ambience_player.play()
	else:
		Debugger.log_error(str("Ambience not found: " + ambience_name))

func stop_music():
	music_player.stop()

func play_sfx(sfx_name: String):
	if sfx_name in sfx_library:
		sfx_player.stream = sfx_library[sfx_name]
		Debugger.log(str("SFX Audio Playing: ", sfx_name))
		sfx_player.play()
	else:
		Debugger.log_error(str("SFX not found: " + sfx_name))

func play_dice_sfx():
	#Change to use collisions to emit sound or additive
	var dice_sfx_keys = dice_sfx_library.keys()  # Get the list of dice sound keys
	var random_key = dice_sfx_keys[randi() % dice_sfx_keys.size()]  # Pick a random key
	Debugger.log(str("Dice Audio Playing: ", random_key))
	sfx_player.stream = dice_sfx_library[random_key]  # Assign the audio stream
	sfx_player.play()  # Play the sound

func set_music_volume(volume: float): #float 0 to 1
	self.musicVolume = volume
	music_player.volume_db = linear_to_db(volume)
	GlobalSettings.profile_settings["music_volume"] = int(volume*100)

func set_ambience_volume(volume: float): #float 0 to 1
	self.ambienceVolume = volume
	ambience_player.volume_db = linear_to_db(volume)
	GlobalSettings.profile_settings["ambience_volume"] = int(volume*100)

func set_sfx_volume(volume: float): #float 0 to 1
	self.sfxVolume = volume
	sfx_player.volume_db = linear_to_db(volume)
	GlobalSettings.profile_settings["sfx_volume"] = int(volume*100)

func get_music_volume() -> float:
	return db_to_linear(music_player.volume_db)
	
func get_ambience_volume() -> float:
	return db_to_linear(ambience_player.volume_db)

func get_sfx_volume() -> float:
	return db_to_linear(sfx_player.volume_db)
