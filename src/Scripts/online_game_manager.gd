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

@onready var GameUI: CanvasLayer = get_node("GameUI")
@onready var rollSelected: Button = get_node("GameUI/RollButtons/RollSelected")
@onready var passRoll: Button = get_node("GameUI/RollButtons/PassRoll")


# Initialization: Connects to signals and retrieves NetworkManager
func _ready() -> void:
	game_settings_ui.connect("game_settings_ready", self._on_settings_ready)
	GameUI.visible = false

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
	GameUI.setup_game_ui(game_settings,network_manager.getIsHost())
	isHost = network_manager.getIsHost()
	network_manager.connect("game_state_received", self._on_game_state_received)
	rollSelected.connect("pressed", self._on_roll_selected)
	passRoll.connect("pressed", self._on_pass_roll)
	setDisableAllButtons(true)
	GameUI.visible = true
	GameUI.hide_waiting_screen()
	current_round = 0
	max_rolls_per_round = game_settings["round_rolls"]
	max_rounds = game_settings["rounds"]
	print("Setup Game Done on Host: ", isHost)
	if isHost:
		await get_tree().create_timer(1.0).timeout
		start_round()

var round_start_done: bool = false

func start_round() ->void:
	waiting_on_other_player(false)
	round_start_done = false
	roll_count = 0
	current_round += 1
	GameUI.update_round_info(current_round)
	GameUI.update_roll_info(roll_count)
	myPlayer.clearRolls()
	enemyPlayer.clearRolls()
	setDisableAllButtons(true)
	if isHost:
		print("Host Started Round")
		network_manager.broadcast_game_state("round_start", { "round": current_round })
		await get_tree().create_timer(1.0).timeout
	else:
		print("Client Started Round")
		await get_tree().create_timer(1.0).timeout
	network_manager.broadcast_game_state("synchronize_start_round", { "round": current_round })
	await get_tree().create_timer(0.1).timeout  # Short delay to ensure propagation
	round_start_done = true

func synchronizeStartRound() -> void:
	print("synchronize start round called by Host: ", !isHost, " on Host: ", isHost)
	#wait for round to start locally
	while !(round_start_done):
		await get_tree().create_timer(1.0).timeout
	round_start_done = false
	#start rolls phase
	rollPhase(true)
	

func rollPhase(roll: bool) -> void:
	setDisableAllButtons(true)
	roll_selection_done = false
	set_rolls_read(false)
	if roll_count == 0:
		myPlayer.roll_dice()
	elif roll:
		myPlayer.roll_selected_dice()
	elif !roll:
		myPlayer.pass_roll()
	roll_count += 1
	GameUI.update_roll_info(roll_count)

func recieveRolls(fromHost: bool, _rolls: Array[int]) ->void:
	enemyPlayer.setRolls(_rolls)
	GameUI.update_opponent_dice_display(_rolls)
	print("Received enemy rolls ", _rolls, " from Host: ", fromHost)
	#wait of rolls read locally
	while !(rolls_read):
		await get_tree().create_timer(1.0).timeout
	rolls_read = false
	await get_tree().create_timer(1.0).timeout
	waiting_on_other_player(false)
	setup_selection()

var rolls_read: bool = false

func set_rolls_read(state: bool) ->void:
	rolls_read = state

func setup_selection() -> void:
	if roll_count >= max_rolls_per_round:
		hand_selection_done = false
		print("Host: ", isHost, " reached hand selection on roll_count: ", roll_count, " of max: ", max_rolls_per_round)
		setDisableScoreBoardButtons(false)
	else:
		roll_selection_done = false
		print("Host: ", isHost, " reached roll selection on roll_count: ", roll_count, " of max: ", max_rolls_per_round)
		setDisableRollButtons(false)

func recieveRollSelection(type: String) -> void:
	#wait on roll selection locally
	while !(roll_selection_done):
		await get_tree().create_timer(1.0).timeout
	roll_selection_done = false
	waiting_on_other_player(false)
	rollPhase(roll_selection)

func recievehand(hand: Dictionary) -> void:
	enemyPlayer.update_score(hand["score"])
	#add code to enemy player to log all hands in order with score
	#wait on hand selection locally
	while !(hand_selection_done):
		await get_tree().create_timer(1.0).timeout
	hand_selection_done = false
	endOfRoundEffects()
	waiting_on_other_player(false)


func endOfRoundEffects() -> void:
	#have a tree of end of round Effects instances to pass the score through and get updated result
	
	#add logic for damage taken and other end of turn effects 
	#calculated locally based on score and totalscore
	var scoreDiff = myPlayer.getLastScore() - enemyPlayer.getLastScore()
	if scoreDiff < 0:
		myPlayer.adjust_health(-1)
		print("Player Host: ", isHost, "scored less")
	elif scoreDiff > 0:
		enemyPlayer.adjust_health(-1)
		print("Player Host: ", isHost, " scored more")
	else:
		print("Players scored the same")
	
	#check engGame Criteria
	if current_round >= max_rounds or myPlayer.getHealth() <= 0 or enemyPlayer.getHealth() <= 0:
		endGame()
	else:
		network_manager.broadcast_game_state("synchronize_next_round", { "round": current_round })
		start_next_round = true

var start_next_round = false

func synchronizeNextRound() -> void:
	print("synchronize next round called by Host: ", !isHost, " on Host: ", isHost)
	#wait for next round locally
	while !(start_next_round):
		await get_tree().create_timer(1.0).timeout
	start_next_round = false
	if(isHost):
		start_round()

func endGame() -> void:
	var myScore = myPlayer.getTotalScore()
	var enemyScore = enemyPlayer.getTotalScore()
	#have a tree of end of game instances to check who wins/ apply effects
	
	var myPlayerStats = myPlayer.getStats()
	var OpponentStats = enemyPlayer.getStats()
	var resultText = "Tied Game"
	if myScore>enemyScore:
		resultText = str(myPlayerStats["player_name"], " wins the game!")
	if myScore<enemyScore:
		resultText = str(OpponentStats["player_name"], " wins the game!")
	print("Game ended")
	GameUI.show_end_of_game_screen(resultText, myPlayerStats, OpponentStats)

func restartGame() ->void:
	pass
	

func exitGame() -> void:
	pass
	

# Handles incoming game states to synchronize players
func _on_game_state_received(state: String, data: Dictionary):
	match state:
		"round_start":
			start_round()
		"synchronize_start_round":
			synchronizeStartRound()
		"synchronize_next_round":
			synchronizeNextRound()
		"roll_values":
			recieveRolls(data["host"],data["rolls"])
		"roll_selection":
			recieveRollSelection(data["type"])
		"hand":
			recievehand(data)
		"test":
			connectionTest(data)

func connectionTest(data: Dictionary) -> void:
	print(data)
	pass

func setup_PlayerManager(settings: Dictionary) -> void:
	myPlayer.setup_player(true, settings["health_points"],game_settings["player_names"][0] if network_manager.getIsHost() else game_settings["player_names"][1], network_manager.getIsHost())
	enemyPlayer.setup_player(false, settings["health_points"],game_settings["player_names"][1] if network_manager.getIsHost() else game_settings["player_names"][0], network_manager.getIsHost())

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
		setDisableAllButtons(true)
		GameUI.show_waiting_screen()
	else:
		GameUI.hide_waiting_screen()

var hand_selection_done: bool = false
var hand_selection: Dictionary

# Function called when a hand is selected
func _on_hand_selected(hand: Dictionary):
	print(hand)
	setDisableScoreBoardButtons(true)
	var score = scoreCalc.calculate_hand_score(hand, myPlayer.getRolls())
	myPlayer.update_score(score)
	scoreboard.updateButtonScore(score)
	hand_selection_done = true
	hand_selection = hand
	print(hand)
	network_manager.broadcast_game_state("hand", { "score": score, "hand": hand["hand_type"] })
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

func returnToIntro()-> void:
	get_parent().returnToIntro()