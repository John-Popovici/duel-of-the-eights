# GameManager.gd

extends Node

@export var dice_container: Node3D   # Reference to DiceContainer node
#@onready var scoreboard = $Scoreboard          # Reference to Scoreboard node
@export var scoreboard: VBoxContainer


@export var total_rounds: int = 5             # Total rounds in the game
var current_round: int = 1                     # Track current round
var current_player: int = 1                    # Track current player
var player_scores = {1: 0, 2: 0}               # Store scores for each player
var player1name: String = ""
var player2name: String  = ""
var currentPlayerName: String = ""


# Start the game
func _ready() -> void:
	#start_round()
	pass

# Begins a round by rolling the dice
func start_round() -> void:
	if current_round > total_rounds:
		end_game()
		return
	
	if current_player == 1:
		currentPlayerName = player1name
	else:
		currentPlayerName = player2name
	print("Round %d, Player %d's turn" % [current_round, current_player])
	
	# Update the scoreboard to indicate current player
	scoreboard.update_turn_status("Player %d's turn" % current_player)
	
	await get_tree().create_timer(1.0).timeout
	# Roll the dice
	dice_container.roll_dice()
	
	# Wait for dice to settle, then update scores (assume 2 seconds for simplicity)
	#yield(get_tree().create_timer(2.0), "timeout")
	await get_tree().create_timer(3.0).timeout
	update_scores()

# Updates scores based on dice results
func update_scores() -> void:
	var dice_values = dice_container.get_dice_values()
	var round_score = calculate_score(dice_values)
	player_scores[current_player] += round_score
	
	# Update scoreboard
	scoreboard.update_player_score(current_player, player_scores[current_player])
	scoreboard.update_total_score(player_scores[current_player])
	
	# Move to next player's turn or next round
	next_turn()

# Calculates score based on dice values (basic example)
func calculate_score(dice_values: Array[int]) -> int:
	# Sum of all dice values, can customize based on scoring rules
	return sum(dice_values)

func sum(arr:Array[int]):
	var result = 0
	for i in arr:
		result+=i
	return result

# Switches to the next player's turn or next round
func next_turn() -> void:
	current_player = 2 if current_player == 1 else 1
	
	# If we've looped back to Player 1, start a new round
	if current_player == 1:
		current_round += 1

	# Start the next round or end game if finished
	if current_round <= total_rounds:
		start_round()
	else:
		end_game()

# Ends the game, displays final scores, and winner
func end_game() -> void:
	var winner = player1name if player_scores[1] > player_scores[2] else player2name
	print("Game Over! Winner: %s" % winner)
	print("Final Scores: Player 1 - %d, Player 2 - %d" % [player_scores[1], player_scores[2]])
	
	# Update scoreboard to show game over and winner
	scoreboard.update_turn_status("Game Over! Winner: %s" % winner)

func setPlayerNames(name1: String,name2: String) -> void:
	player1name = name1
	player2name = name2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
