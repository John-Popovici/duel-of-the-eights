extends Node3D

# IntroScene.gd

@onready var player1_name_input = $VBoxContainer/Player1Entry  # Reference to Player 1's LineEdit
@onready var player2_name_input = $VBoxContainer/Player2Entry  # Reference to Player 2's LineEdit
@onready var start_local_button = $VBoxContainer/StartLocalGame # Reference to the Start Button
@onready var start_standard_button = $VBoxContainer/StartStandardGame # Reference to the Start Button
@onready var start_bluff_button = $VBoxContainer/StartBluffGame # Reference to the Start Button
@onready var start_blitz_button = $VBoxContainer/StartBlitzGame # Reference to the Start Button
@onready var start_online_button = $VBoxContainer/StartOnlineGame # Reference to the Start Button
@onready var start_online_long_form_button = $VBoxContainer/StartOnlineLongFormGame # Reference to the Start Button
@onready var start_online_server_button = $VBoxContainer/StartServer
@onready var customization_button = $OptionsPanel/VBoxContainer/Customization
@onready var tutorial_button = $OptionsPanel/VBoxContainer/Tutorial
@onready var settings_button = $OptionsPanel/VBoxContainer/Settings
@onready var profile_button = $OptionsPanel/VBoxContainer/Profile

# Called when the node enters the scene tree
func _ready() -> void:
	start_local_button.pressed.connect(_on_start_local_game_pressed)
	start_online_button.pressed.connect(_on_start_online_game_pressed)
	start_standard_button.pressed.connect(_on_start_standard_game_pressed)
	start_bluff_button.pressed.connect(_on_start_bluff_game_pressed)
	start_blitz_button.pressed.connect(_on_start_blitz_game_pressed)
	start_online_long_form_button.pressed.connect(_on_start_online_long_form_game_pressed)
	start_online_server_button.pressed.connect(_on_start_online_server_pressed);
	customization_button.pressed.connect(_on_customization_pressed)
	tutorial_button.pressed.connect(_on_tutorial_button)
	settings_button.pressed.connect(_on_settings_pressed)
	profile_button.pressed.connect(_on_profile_pressed)
	AudioManager.connect_buttons()

# Transition to GameScene with player names
func _on_start_local_game_pressed() -> void:
	var player1_name = player1_name_input.text
	var player2_name = player2_name_input.text
	
	# Load GameScene
	var local_game_scene = load("res://Scenes/local_game_scene.tscn").instantiate()
	
	# Pass player names to GameScene
	local_game_scene.set_player_names(player1_name, player2_name)
	
	# Change scene to GameScene
	get_tree().root.add_child(local_game_scene)
	queue_free()  # Free IntroScene

func _on_start_online_game_pressed() -> void:
	# Load GameScene
	SceneSwitcher.changeScene("res://Scenes/online_game_scene.tscn")

func _on_start_standard_game_pressed() -> void:
	# Load GameScene
	SceneSwitcher.changeScene("res://Scenes/online_standard_game_scene.tscn")

func _on_start_bluff_game_pressed() -> void:
	# Load GameScene
	SceneSwitcher.changeScene("res://Scenes/online_bluff_game_scene.tscn")

func _on_start_blitz_game_pressed() -> void:
	# Load GameScene
	SceneSwitcher.changeScene("res://Scenes/online_blitz_game_scene.tscn")

func _on_start_online_long_form_game_pressed() -> void:
	# Load GameScene
	SceneSwitcher.changeScene("res://Scenes/online_long_form_pvp_scene.tscn")

func _on_start_online_server_pressed() -> void:
	# Load GameScene
	SceneSwitcher.changeScene("res://Scenes/online_server_game_scene.tscn")

# Transition to GameScene with player names
func _on_customization_pressed() -> void:
	# Load GameScene
	SceneSwitcher.changeScene("res://Scenes/global_customization_scene.tscn")

func _on_tutorial_button() -> void:
	# Load GameScene
	SceneSwitcher.changeScene("res://Scenes/tutorial_scene.tscn")

func _on_settings_pressed() -> void:
	# Load GameScene
	SceneSwitcher.changeScene("res://Scenes/player_settings_scene.tscn")
	
func _on_profile_pressed() -> void:
	# Load profile overlay
	SceneSwitcher.changeScene("res://Scenes/player_profile_scene.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
