extends Node

@onready var game_settings_ui = get_node("GameSettings")
@onready var single_game_manager = get_node("GameManager")
@onready var networkManagers = get_tree().get_nodes_in_group("NetworkHandlingNodes")
@onready var NetworkManager = networkManagers[0]

var game_settings: Dictionary
var hand_settings: Dictionary

var current_game_count = 0
var total_games = 8
var player1_wins = 0
var player2_wins = 0

func start_next_game():
	if current_game_count < total_games:
		# Initialize game settings and start the individual game
		start_game()
	else:
		# End the multi-game session
		end_game()

func start_game():
	current_game_count += 1
	single_game_manager._on_settings_ready(game_settings,hand_settings)
	game_settings_ui.visible = false

func finish_game(resultText, myPlayerFinalStats, OpponentFinalStats):
	pass
	# Determine winner of the current game, track results
	#if winner == "Player 1":
	#	player1_wins += 1
	#else:
	#	player2_wins += 1
	
	# Go to customization menu
	#customization_menu.show_customization(winner)

func end_game():
	pass
	# Determine the final winner based on win condition
	#var overall_winner = calculate_final_winner()
	#display_end_screen(overall_winner)


func loadGameSetup():
	game_settings_ui.collectInfo()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_settings_ui.connect("game_settings_ready", self._on_settings_ready)
	NetworkManager.connect("received_game_settings", self.receive_game_settings)

func _on_settings_ready(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	game_settings = _game_settings
	hand_settings = _hand_settings
	if NetworkManager.getIsHost():
		print("Reached host send")
		NetworkManager.send_game_settings(game_settings,hand_settings)
	start_next_game()

func receive_game_settings(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	game_settings = _game_settings
	hand_settings = _hand_settings
	print("Reached recieve settings")
	start_next_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
