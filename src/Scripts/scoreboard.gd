# Scoreboard.gd

extends VBoxContainer

# Labels for individual categories and scores
@onready var player1_score_label = $Player1ScoreContainer/Player1Score
@onready var player2_score_label = $Player2ScoreContainer/Player2Score

@onready var total_score_label = $TotalScoreContainer/TotalScore
@onready var dice_values_label = $CurrentDiceRollsContainer/CurrentDiceRolls
@export var turn_status_label: Label


# Function to update player score
func update_player_score(player: int, score: int) -> void:
	if player == 1:
		player1_score_label.text = str(score)
	elif player == 2:
		player2_score_label.text = str(score)

# Function to update total score
func update_total_score(score: int) -> void:
	total_score_label.text = str(score)

# Function to update dice value display
func update_dice_values(values: Array[int]) -> void:
	dice_values_label.text = str(values)

# Function to update the turn indicator
func update_turn_status(player_name: String) -> void:
	turn_status_label.text = str(player_name)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass