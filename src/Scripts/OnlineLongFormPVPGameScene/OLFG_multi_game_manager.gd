extends Node

@onready var game_settings_ui = get_node("GameSettings")
@onready var single_game_manager = get_node("GameManager")


var current_game_count = 0
var total_games = 0
var player1_wins = 0
var player2_wins = 0

func start_next_game():
	if current_game_count < total_games:
		# Initialize game settings and start the individual game
		single_game_manager.start_game()
	else:
		# End the multi-game session
		end_game()

func finish_game(winner: String):
	# Determine winner of the current game, track results
	if winner == "Player 1":
		player1_wins += 1
	else:
		player2_wins += 1

	current_game_count += 1
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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
