extends Node

# Player attributes
var score: int = 0
var last_score: int = 0
var health_points: int = 10  # Example starting health
var rolls: Array = []  # Stores current dice rolls
var selected_hand: Dictionary = {}
var selected_for_reroll: Array = []  # Dice selected to reroll
var myPlayer: bool
var playerName: String
var hostDevice: bool
var diceContainer: Node3D
var network_manager: Node
var game_manager: Node3D
var GameUI: CanvasLayer

# Initialize player with default values or game settings
func setup_player(_myPlayer: bool, initial_health: int, _playerName: String, _hostDevice: bool):
	health_points = initial_health
	score = 0
	playerName = _playerName
	rolls.clear()
	selected_for_reroll.clear()
	myPlayer = _myPlayer
	hostDevice = _hostDevice
	diceContainer = get_parent().get_node("DiceContainer")
	network_manager = get_parent().get_parent().get_node("NetworkManager")
	game_manager = get_parent()
	GameUI = get_parent().get_node("GameUI")

# Update the player's score and health based on the round outcome
func update_score(new_score: int):
	score += new_score
	last_score = new_score
	GameUI.update_player_stats("Player" if myPlayer else "Opponent",playerName,health_points, score)

func getTotalScore() -> int:
	return score

func getLastScore() -> int:
	return last_score

func adjust_health(points: int):
	health_points += points  # Can be positive or negative
	GameUI.update_player_stats("Player" if myPlayer else "Opponent",playerName,health_points, score)

func getHealth() -> int:
	return health_points

func roll_dice() -> void:
	diceContainer.roll_dice()
	await get_tree().create_timer(1.0).timeout
	checkIfDiceValidThenRead()

func roll_selected_dice() -> void:
	diceContainer.roll_selected_dice()
	await get_tree().create_timer(1.0).timeout
	checkIfDiceValidThenRead()

func roll_rolling_or_invalid_dice() -> void:
	diceContainer.roll_rolling_or_invalid_dice()


func pass_roll() -> void:
	checkIfDiceValidThenRead()

func checkIfDiceValidThenRead() -> void:
	var timeTillReroll = 5
	while len(diceContainer.get_rolling_dice()) > 0 or len(diceContainer.get_invalid_dice()) > 0:
		timeTillReroll -=1
		await get_tree().create_timer(1.0).timeout
		if timeTillReroll <= 0:
			timeTillReroll = 5
			roll_rolling_or_invalid_dice()
			await get_tree().create_timer(1.0).timeout
	readRolls()

func readRolls() -> void:
	#Wait for dice to stop
	while !(len(diceContainer.get_rolling_dice()) == 0):
		await get_tree().create_timer(1.0).timeout
	rolls = diceContainer.get_dice_values()
	game_manager.set_rolls_read(true)
	#Communicate to other player
	print("Player Manger: Host: ", hostDevice, ", Rolls: ", rolls)
	network_manager.broadcast_game_state("roll_values", { "host": hostDevice, "rolls": rolls })
	game_manager.waiting_on_other_player(true)


func setRolls(_rolls: Array) -> void:
	rolls = _rolls

func getRolls() -> Array:
	return rolls

func clearRolls() -> void:
	rolls.clear()

func getStats() -> Dictionary:
	var player_stats = {
		"player_name": playerName,
		"health_points": health_points,
		"score": score,
	}
	return player_stats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
