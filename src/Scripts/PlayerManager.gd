extends Node

# Player attributes
var score: int = 0
var health_points: int = 10  # Example starting health
var rolls: Array = []  # Stores current dice rolls
var selected_hand: Dictionary = {}
var selected_for_reroll: Array = []  # Dice selected to reroll
var repHostPlayer: bool
var hostDevice: bool
var diceContainer: Node3D

# Initialize player with default values or game settings
func setup_player(_repHostPlayer: bool, initial_health: int, _hostDevice: bool):
	health_points = initial_health
	score = 0
	rolls.clear()
	selected_for_reroll.clear()
	repHostPlayer = _repHostPlayer
	hostDevice = _hostDevice
	diceContainer = get_parent().get_node("DiceContainer")

# Update the player's score and health based on the round outcome
func update_score(new_score: int):
	score += new_score

func adjust_health(points: int):
	health_points += points  # Can be positive or negative

func rollDice() -> void:
	diceContainer.roll_dice()

func rollSelected() -> void:
	diceContainer.roll_selected_dice()

func readRolls() -> void:
	rolls = diceContainer.get_dice_values()

func getRolls() -> Array:
	return rolls

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
