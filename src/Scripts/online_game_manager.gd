extends Node3D

var game_settings
@onready var game_settings_ui = get_node("GameSettings")
@onready var network_manager = get_node("../NetworkManager")
@onready var dice_container = get_node("DiceContainer")

# Initialization: Connects to signals and retrieves NetworkManager
func _ready() -> void:
	game_settings_ui.connect("game_settings_ready", self._on_settings_ready)

# Process game settings from GameSettings UI
func _on_settings_ready(settings: Dictionary) -> void:
	game_settings = settings
	if network_manager.getIsHost():
		network_manager.send_game_settings(game_settings)

	# Set up the game environment with these settings
	setup_game_environment(game_settings)

func startGame() -> void:
	game_settings_ui.collectInfo()

# Client receives the game settings from host
func receive_game_settings(settings: Dictionary) -> void:
	game_settings = settings
	game_settings_ui.visible = false
	setup_game_environment(game_settings)

# Function to dynamically set up game environment based on settings
func setup_game_environment(settings: Dictionary) -> void:
	# Initialize game variables and UI, create dice dynamically
	dice_container.clear_dice()
	dice_container.add_dice(settings["dice_count"],int(settings["dice_type"]))

	# Additional setup can go here
	if network_manager.getIsHost():
		print("Host Game initialized with settings:", settings)
	else:
		print("Client Game initialized with settings:", settings)
