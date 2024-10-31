# GameManager.gd

extends Node

@onready var dice_container = $DiceContainer   # Reference to DiceContainer node
@onready var scoreboard = $CanvasLayer/ScoreboardContatiner          # Reference to Scoreboard node
@onready var P1HandsContainer: VBoxContainer         # Reference to HandsContainer node
@onready var P2HandsContainer: VBoxContainer         # Reference to HandsContainer node
@onready var roll_selected_button = $CanvasLayer/ControlButtons/RollSelectedDiceButton # Reference to the Roll Selected Button
@onready var start_game_button = $CanvasLayer/ControlButtons/StartGameButton # Reference to the Pass Button

@export var total_rounds: int = 5             # Total rounds in the game
var current_round: int = 1                     # Track current round
var current_player: int = 1                    # Track current player
var player_scores = {1: 0, 2: 0}               # Store scores for each player
var player1name: String = ""
var player2name: String  = ""
var currentPlayerName: String = ""
var roll_phase: int = 0  # Tracks which roll phase we're in (0 = first roll, 1/2 = re-rolls)
var max_rolls: int = 2

# Start the game
func _ready() -> void:
	roll_selected_button.pressed.connect(roll_selected_button_call)
	start_game_button.pressed.connect(start_round)
	P1HandsContainer = get_node("CanvasLayer/P1HandsContainer")
	P2HandsContainer = get_node("CanvasLayer/P2HandsContainer")
	P1HandsContainer.OffVisibility()
	P2HandsContainer.OffVisibility()

func roll_selected_button_call() -> void:
	if roll_phase < max_rolls:
		dice_container.roll_selected_dice()
		roll_phase += 1
	elif roll_phase == max_rolls:
		# Disable buttons when no more rolls are allowed
		roll_selected_button.disabled = true
		dice_container.roll_selected_dice()


# Begins a round by rolling the dice
func start_round() -> void:
	if current_round > total_rounds:
		end_game()
		return
	
	roll_phase = 0
	roll_selected_button.disabled = true  # Disable initially, enabled after first roll
	start_game_button.disabled = true
	start_game_button.visible = false
	
	if current_player == 1:
		currentPlayerName = player1name
		P1HandsContainer.OnVisibility()
		P2HandsContainer.OffVisibility()
	else:
		currentPlayerName = player2name
		P1HandsContainer.OffVisibility()
		P2HandsContainer.OnVisibility()
	print("Round %d, Player %d's turn" % [current_round, current_player])
	
	# Update the scoreboard to indicate current player
	scoreboard.update_turn_status("Player %d's turn" % current_player)
	
	#First Roll (all)
	dice_container.roll_dice()
	roll_phase += 1
	roll_selected_button.disabled = false  # Disable initially, enabled after first roll



# Updates scores based on dice results
func update_scores(round_score: int) -> void:
	#var dice_values = dice_container.get_dice_values()
	#var round_score = calculate_score(dice_values)
	player_scores[current_player] += round_score
	
	# Update scoreboard
	scoreboard.update_player_score(current_player, player_scores[current_player])
	scoreboard.update_total_score(player_scores[current_player])
	scoreboard.update_dice_values(dice_container.get_dice_values())
	
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
	var winner
	if player_scores[1] > player_scores[2]:
		winner = player1name
	elif player_scores[1] < player_scores[2]:
		winner = player2name
	else:
		winner = "Both Players! (Or none, depending on how you look at it)"
	print("Game Over! Winner: %s" % winner)
	print("Final Scores: Player 1 - %d, Player 2 - %d" % [player_scores[1], player_scores[2]])
	P1HandsContainer.OffVisibility()
	P2HandsContainer.OffVisibility()
	# Update scoreboard to show game over and winner
	scoreboard.update_turn_status("Game Over! Winner: %s" % winner)

func setPlayerNames(name1: String,name2: String) -> void:
	player1name = name1
	player2name = name2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
