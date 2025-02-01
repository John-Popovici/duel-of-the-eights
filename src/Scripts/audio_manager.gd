extends Node

@onready var music_player = $MusicPlayer
@onready var sfx_player = $SFXPlayer

# Dictionary of sound effects
var sfx_library = {
	#"dice_roll": preload("res://Audio/SFX/dice_roll.wav"),
	#"button_click": preload("res://Audio/SFX/button_click.wav"),
	#"win_sound": preload("res://Audio/SFX/win_sound.wav")
}

# Dictionary of background music tracks
var music_library = {
	#"main_menu": preload("res://Audio/Music/main_menu.ogg"),
	#"gameplay": preload("res://Audio/Music/gameplay.ogg")
}

func _ready():
	# Set default volume levels
	music_player.volume_db = -10  # Default lower volume
	music_player.loop = true
	sfx_player.volume_db = -5  

func play_music(track_name: String, loop: bool = true):
	if track_name in music_library:
		music_player.stream = music_library[track_name]
		music_player.play()
		music_player.loop = loop
	else:
		push_error("Music track not found: " + track_name)

func stop_music():
	music_player.stop()

func play_sfx(sfx_name: String):
	if sfx_name in sfx_library:
		sfx_player.stream = sfx_library[sfx_name]
		sfx_player.play()
	else:
		push_error("SFX not found: " + sfx_name)

func set_music_volume(volume: float):
	music_player.volume_db = linear_to_db(volume)  

func set_sfx_volume(volume: float):
	sfx_player.volume_db = linear_to_db(volume)  
