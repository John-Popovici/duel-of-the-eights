extends Node

# Player attributes
var score: int = 0
var last_score: int = 0
var health_points: int = 10  # Example starting health
var rolls: Array = []  # Stores current dice rolls
var dice : Array[RigidBody3D]
var selected_hand: Dictionary = {}
var myPlayer: bool
var playerName: String
var hostDevice: bool
var diceContainer: Node3D
@onready var networkManagers = get_tree().get_nodes_in_group("NetworkHandlingNodes")
var network_manager

# Initialize player with default values or game settings
func setup_player(_myPlayer: bool, initial_health: int, _playerName: String, _hostDevice: bool, _dice_container):
	health_points = initial_health
	score = 0
	playerName = _playerName
	rolls.clear()
	myPlayer = _myPlayer
	hostDevice = _hostDevice
	diceContainer = _dice_container

# Update the player's score and health based on the round outcome
func update_score(new_score: int):
	score += new_score
	last_score = new_score
	emit_signal("player_stats_updated","Player" if myPlayer else "Opponent",getStats())

func getTotalScore() -> int:
	return score

func getLastScore() -> int:
	return last_score

func adjust_health(points: int):
	health_points += points  # Can be positive or negative
	emit_signal("player_stats_updated","Player" if myPlayer else "Opponent",getStats())

signal player_stats_updated(_player: String, Stats: Dictionary)

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
	await get_tree().create_timer(1.0).timeout
	checkIfDiceValidThenRead()

func checkIfDiceValidThenRead() -> void:
	var timeTillReroll = diceContainer.get_dice()[0].roll_time_limit
	while len(diceContainer.get_rolling_dice()) > 0 or len(diceContainer.get_invalid_dice()) > 0:
		timeTillReroll -=1
		await get_tree().create_timer(1.0).timeout
		if timeTillReroll <= 0:
			timeTillReroll = diceContainer.get_dice()[0].roll_time_limit
			roll_rolling_or_invalid_dice()
			await get_tree().create_timer(1.0).timeout
	readRolls()

signal rollsReadandWaiting(state: bool)

func readRolls() -> void:
	#Wait for dice to stop
	while !(len(diceContainer.get_rolling_dice()) == 0):
		await get_tree().create_timer(1.0).timeout
	rolls = diceContainer.get_dice_values()
	dice = diceContainer.get_dice()
	diceContainer.moveDiceInLine()
	emit_signal("rollsReadandWaiting",true)
	#Communicate to other player
	print("Player Manger: Host: ", hostDevice, ", Rolls: ", rolls)
	if len(networkManagers) ==1:
		network_manager.broadcast_game_state("roll_values", { "host": hostDevice, "rolls": rolls })


func setRolls(_rolls: Array) -> void:
	rolls = _rolls

func getRolls() -> Array:
	return rolls

func get_dice() -> Array[RigidBody3D]:
	return dice

func clearRolls() -> void:
	rolls.clear()

func getStats() -> Dictionary:
	var player_stats = {
		"Name": playerName,
		"Health points": health_points,
		"Score": score,
	}
	return player_stats

func getState() -> Dictionary:
	var playerState ={
		"player_name": playerName,
		"health_points": health_points,
		"score": score,
		"rolls": rolls,
		"dice": dice,
		"selected_hand": selected_hand,
		"myPlayer":myPlayer,
		"hostDevice":hostDevice,
		"diceContainer":diceContainer
	}
	return playerState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if len(networkManagers) == 1:
		network_manager = networkManagers[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
