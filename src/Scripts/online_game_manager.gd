extends Node3D

var game_settings
var hand_settings
@onready var game_settings_ui = get_node("GameSettings")
@onready var network_manager = get_node("../NetworkManager")
@onready var dice_container = get_node("DiceContainer")

# Initialization: Connects to signals and retrieves NetworkManager
func _ready() -> void:
	game_settings_ui.connect("game_settings_ready", self._on_settings_ready)

# Process game settings from GameSettings UI (Host side)
func _on_settings_ready(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	game_settings = _game_settings
	hand_settings = _hand_settings
	if network_manager.getIsHost():
		network_manager.send_game_settings(game_settings,hand_settings)

	# Set up the game environment with these settings
	setup_game()

func loadGameSetup() -> void:
	game_settings_ui.collectInfo()

# Client receives the game settings from host
func receive_game_settings(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	game_settings = _game_settings
	hand_settings = _hand_settings
	game_settings_ui.visible = false
	setup_game()

func setup_game() -> void:
	setup_game_environment(game_settings)
	setup_hands_scoreboard(hand_settings)
	setup_UI()

func setup_UI() -> void:
	#clear anything generated and re build
	pass

func setup_hands_scoreboard(_hands_settings: Dictionary) -> void:
	#clear anything generated and re build
	pass

# Function to dynamically set up game environment based on settings
func setup_game_environment(_game_settings: Dictionary) -> void:
	# Initialize game variables and UI, create dice dynamically
	dice_container.clear_dice()
	dice_container.add_dice(_game_settings["dice_count"],int(_game_settings["dice_type"]))

	#add any other physical 3D setup

	# Additional setup can go here
	if network_manager.getIsHost():
		print("Host Game Environment initialized with settings:", _game_settings)
	else:
		print("Client Game Environment initialized with settings:", _game_settings)
