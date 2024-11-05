extends Node3D

var game_settings
var hand_settings
@onready var game_settings_ui = get_node("GameSettings")
@onready var network_manager = get_node("../NetworkManager")
@onready var dice_container = get_node("DiceContainer")
@onready var scoreboard = get_node("Scoreboard")
@onready var scoreCalc = get_node("ScoreCalculator")
@onready var myPlayer = get_node("myPlayer")
@onready var enemyPlayer = get_node("enemyPlayer")
var isHost: bool

var max_rounds: int
var max_rolls_per_round: int

var current_round: int = 0
var roll_count: int = 0
var game_over: bool = false

@onready var RoundUI: CanvasLayer = get_node("RoundUI")
@onready var rollSelected: Button = get_node("RoundUI/RollButtons/RollSelected")
@onready var passRoll: Button = get_node("RoundUI/RollButtons/PassRoll")


# Initialization: Connects to signals and retrieves NetworkManager
func _ready() -> void:
	game_settings_ui.connect("game_settings_ready", self._on_settings_ready)
	RoundUI.visible = false

# Process game settings from GameSettings UI (Host side)
func _on_settings_ready(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	game_settings = _game_settings
	hand_settings = _hand_settings
	max_rounds = game_settings["rounds"]
	max_rolls_per_round = game_settings["round_rolls"]
	
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
	setup_scoreboard(hand_settings)
	setup_PlayerManager(game_settings)
	isHost = network_manager.getIsHost()
	network_manager.connect("game_state_received", self._on_game_state_received)
	rollSelected.connect("pressed", self._on_roll_selected)
	passRoll.connect("pressed", self._on_pass_roll)
	setDisableAllButtons(true)
	RoundUI.visible = true
	current_round = 0
	max_rolls_per_round = game_settings["round_rolls"]
	max_rounds = game_settings["rounds"]
	print("Setup Game Done")
	if isHost:
		await get_tree().create_timer(1.0).timeout
		start_round()

func start_round() ->void:
	waiting_on_other_player(false)
	roll_count = 0
	current_round += 1
	myPlayer.clearRolls()
	enemyPlayer.clearRolls()
	setDisableAllButtons(true)
	if isHost:
		print("Host Started Round")
		await get_tree().create_timer(1.0).timeout
		network_manager.broadcast_game_state("round_start", { "round": current_round })
	else:
		print("Client Started Round")
		await get_tree().create_timer(1.0).timeout
	rollPhase(true)

func rollPhase(roll: bool) -> void:
	setDisableAllButtons(true)
	roll_selection_done = false
	roll_count += 1
	if roll_count == 0:
		myPlayer.roll_dice()
	elif roll:
		myPlayer.roll_selected_dice()
	elif !roll:
		myPlayer.pass_roll()

func recieveRolls(fromHost: bool, _rolls: Array[int]) ->void:
	enemyPlayer.setRolls(_rolls)
	print("Received enemy rolls ", _rolls, " from Host: ", fromHost)
	myPlayer.waitForDiceStop()
	waiting_on_other_player(false)
	setup_selection()

func setup_selection() -> void:
	if roll_count >= max_rolls_per_round:
		print("Host: ", isHost, " reached hand selection on roll_count: ", roll_count, " of max: ", max_rolls_per_round)
		hand_selection_done = false
		setDisableScoreBoardButtons(false)
	else:
		print("Host: ", isHost, " reached roll selection on roll_count: ", roll_count, " of max: ", max_rolls_per_round)
		setDisableRollButtons(false)

func recieveRollSelection(type: String) -> void:
	waiting_on_roll_selection()
	doRollSelection()
	waiting_on_other_player(false)

func waiting_on_roll_selection() -> bool:
	while !(roll_selection_done):
		await get_tree().create_timer(1.0).timeout
	return true

func doRollSelection() -> void:
	rollPhase(roll_selection)

func recievehand(hand: Dictionary) -> void:
	enemyPlayer.update_score(hand["score"])
	waiting_on_hand_selection()
	endOfRoundEffects()
	waiting_on_other_player(false)

func waiting_on_hand_selection() -> bool:
	while !(hand_selection_done):
		await get_tree().create_timer(1.0).timeout
	return true

func endOfRoundEffects() -> void:
	#add logic for damage taken and other end of turn effects 
	#calculated locally based on score and totalscore
	var scoreDiff = myPlayer.getLastScore() - enemyPlayer.getLastScore()
	if scoreDiff < 0:
		myPlayer.adjust_health(-1)
	elif scoreDiff > 0:
		enemyPlayer.adjust_health(-1)
	
	#check engGame Criteria
	if current_round >= max_rounds or myPlayer.getHealth() <= 0 or enemyPlayer.getHealth() <= 0:
		endGame()
	elif isHost:
		start_round()

func endGame() -> void:
	print("Game ended")

# Handles incoming game states to synchronize players
func _on_game_state_received(state: String, data: Dictionary):
	match state:
		"round_start":
			start_round()
		"roll_values":
			recieveRolls(data["host"],data["rolls"])
		"roll_selection":
			recieveRollSelection(data["type"])
		"hand":
			recievehand(data)

func setup_PlayerManager(settings: Dictionary) -> void:
	myPlayer.setup_player(true, settings["health_points"], network_manager.getIsHost())
	enemyPlayer.setup_player(false, settings["health_points"], network_manager.getIsHost())

func setup_scoreboard(_hand_settings: Dictionary) -> void:
	#clear anything generated and re build
	scoreCalc.initializeValues()
	scoreCalc.BonusTriggered.connect(self._on_bonus_triggered)
	scoreboard.bonusExists.connect(self._on_bonus_exist)
	scoreboard.populate_scoreboard(_hand_settings)
	scoreboard.hand_selected.connect(self._on_hand_selected)

func setDisableAllButtons(state: bool) -> void:
	setDisableScoreBoardButtons(state)
	setDisableRollButtons(state)
	#Add more buttons such as roll dice and so on

func setDisableScoreBoardButtons(state: bool) -> void:
	scoreboard.setAllButtonsDisable(state)

func setDisableRollButtons(state: bool) -> void:
	rollSelected.disabled = state
	passRoll.disabled = state

var roll_selection_done: bool = false
var roll_selection: bool

func _on_roll_selected() -> void:
	setDisableRollButtons(true)
	network_manager.broadcast_game_state("roll_selection", { "type": "Roll" })
	roll_selection = true
	roll_selection_done = true
	waiting_on_other_player(true)

func _on_pass_roll() -> void:
	setDisableRollButtons(true)
	network_manager.broadcast_game_state("roll_selection", { "type": "Pass" })
	roll_selection = false
	roll_selection_done = true
	waiting_on_other_player(true)

func waiting_on_other_player(isWaiting: bool) -> void:
	if isWaiting:
		pass
	else:
		pass

var hand_selection_done: bool = false
var hand_selection: Dictionary

# Function called when a hand is selected
func _on_hand_selected(hand: Dictionary):
	print(hand)
	setDisableScoreBoardButtons(true)
	var score = scoreCalc.calculate_hand_score(hand, dice_container.get_dice_values())
	myPlayer.update_score(score)
	scoreboard.updateButtonScore(score)
	hand_selection_done = true
	hand_selection = hand
	network_manager.broadcast_game_state("hand", { "score": score, "hand": hand["hand"] })
	# Logic to proceed to next player's turn if necessary

func _on_bonus_exist(_hand: Dictionary) -> void:
	scoreCalc.setupBonus(_hand)

func _on_bonus_triggered(_score):
	#apply_score_to_player(score) #implement in Player Manager !!!!!!!!!!!
	scoreboard.updateBonusButtonScore(_score)

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
