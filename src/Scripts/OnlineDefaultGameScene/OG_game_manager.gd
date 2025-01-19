extends Node3D

var game_settings
var hand_settings
@onready var networkManagers = get_tree().get_nodes_in_group("NetworkHandlingNodes")
@onready var network_manager = networkManagers[0]
@onready var dice_container = get_node("DiceContainer")
@onready var scoreboard = get_node("Scoreboard")
@onready var scoreCalc = get_node("ScoreCalculator")
@onready var myPlayer = get_parent().get_node("myPlayer")
@onready var enemyPlayer = get_parent().get_node("enemyPlayer")

@onready var GameUI: CanvasLayer = get_node("GameUI")
@onready var rollButtons = get_node("RollButtons")
@onready var rollSelected: Button = get_node("RollButtons/RollSelected")
@onready var passRoll: Button = get_node("RollButtons/PassRoll")
@onready var BluffButtons = get_node("BluffContainer")
@onready var raiseTheStakesButton: Button = get_node("BluffContainer/RaiseTheStakesButton")
@onready var foldButton: Button = get_node("BluffContainer/FoldButton")
var isHost: bool
var baseTimer: int
var timedRounds: bool
var bluffMechanicActive: bool
var raiseInEffect: bool
var blockRaise: bool

var max_rounds: int
var max_rolls_per_round: int
var win_cond: int

var current_round: int = 0
var roll_count: int = 0
var game_over: bool = false


# Initialization: Connects to signals and retrieves NetworkManager
func _ready() -> void:
	GameUI.visible = false
	myPlayer.connect("rollsReadandWaiting", self.set_rolls_read)
	myPlayer.connect("rollsReadandWaiting", self.waiting_on_other_player)
	myPlayer.connect("player_stats_updated", self.update_player_stats_signal)
	enemyPlayer.connect("player_stats_updated", self.update_player_stats_signal)

signal update_player_stats(_player: String, Stats: Dictionary)
func update_player_stats_signal(_player: String, Stats: Dictionary) -> void:
	emit_signal("update_player_stats",_player,Stats)

# Process game settings and start game
func _on_settings_ready(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	game_settings = _game_settings
	hand_settings = _hand_settings
	max_rounds = game_settings["rounds"]
	max_rolls_per_round = game_settings["round_rolls"]
	win_cond = game_settings["win_condition"]
	baseTimer = game_settings["round_time"]
	timedRounds = game_settings["timed_rounds"]
	bluffMechanicActive = game_settings["bluff_active"]
	# Set up the game environment with these settings
	setup_game()


func setup_game() -> void:
	setup_game_environment(game_settings)
	setup_scoreboard(hand_settings)
	setup_PlayerManager(game_settings)
	print("Setup UI Called on Host: ", network_manager.getIsHost())
	GameUI.setup_game_ui(game_settings,network_manager.getIsHost())
	rollButtons.visible = true
	print("Setup UI Finished Calling Called on Host: ", network_manager.getIsHost())
	isHost = network_manager.getIsHost()
	network_manager.connect("game_state_received", self._on_game_state_received)
	rollSelected.connect("pressed", self._on_roll_selected)
	passRoll.connect("pressed", self._on_pass_roll)
	raiseTheStakesButton.connect("pressed", self._on_raise)
	foldButton.connect("pressed", self._on_fold)
	setDisableAllButtons(true)
	GameUI.visible = true
	GameUI.hide_waiting_screen()
	current_round = 0
	max_rolls_per_round = game_settings["round_rolls"]
	max_rounds = game_settings["rounds"]
	if bluffMechanicActive:
		BluffButtons.visible = true
		raiseTheStakesButton.visible = true
		foldButton.visible = false
		raiseInEffect = false
		blockRaise = false
		setDisableRaiseButtons(true)
	else:
		BluffButtons.visible = false
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
	GameUI.blank_opponent_dice_display()
	GameUI.blank_my_player_dice_display()
	set_rolls_read(false)
	blockRaise = false
	if roll_count == 0:
		myPlayer.roll_dice()
		resetRaise()
	elif roll:
		myPlayer.roll_selected_dice()
	elif !roll:
		myPlayer.pass_roll()
	roll_count += 1
	if roll_count == max_rolls_per_round: #Check if this comp is correct
		blockRaiseButton(true)
		setDisableRaiseButtons(true)
	else:
		blockRaiseButton(false)
		setDisableRaiseButtons(false)
	GameUI.update_roll_info(roll_count)

func recieveRolls(fromHost: bool, _rolls: Array[int]) ->void:
	enemyPlayer.setRolls(_rolls)
	GameUI.update_opponent_dice_display(_rolls)
	print("Received enemy rolls ", _rolls, " from Host: ", fromHost)
	#wait of rolls read locally
	while !(rolls_read):
		await get_tree().create_timer(1.0).timeout
	GameUI.update_my_player_dice_display(myPlayer.get_dice())
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
		if timedRounds:
			GameUI.startTimer(baseTimer*2)
	else:
		roll_selection_done = false
		print("Host: ", isHost, " reached roll selection on roll_count: ", roll_count, " of max: ", max_rolls_per_round)
		setDisableRollButtons(false)
		if timedRounds:
			GameUI.startTimer(baseTimer)

func recieveRollSelection(_type: String) -> void:
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

func recievebonus(hand: Dictionary) -> void:
	enemyPlayer.update_score(hand["score"])
	#add code to enemy player to log all hands in order with score

func endOfRoundEffects() -> void:
	#have a tree of end of round Effects instances to pass the score through and get updated result
	
	#add logic for damage taken and other end of turn effects 
	#calculated locally based on score and totalscore
	var end_condition_reached = false
	print("WinCondition: ",win_cond)
	match win_cond:
		0: #score
			var scoreDiff = myPlayer.getLastScore() - enemyPlayer.getLastScore()
			if scoreDiff < 0:
				print("Player Host: ", isHost, " scored less")
			elif scoreDiff > 0:
				print("Player Host: ", isHost, " scored more")
			else:
				print("Players scored the same")
			#check engGame Criteria
			if current_round >= max_rounds:
				end_condition_reached = true
		1: #Health Points
			var scoreDiff = myPlayer.getLastScore() - enemyPlayer.getLastScore()
			print("MyPlayer Host: ", isHost, " scored: ", myPlayer.getLastScore(), " and EnemyPlayer Host: ", !isHost, " scored: ", enemyPlayer.getLastScore())
			if scoreDiff < 0:
				if raiseInEffect:
					myPlayer.adjust_health(-1) # make this dyanmic
				myPlayer.adjust_health(-1) # make this dyanmic
				print("Player Host: ", isHost, "scored less, took damage")
			elif scoreDiff > 0:
				if raiseInEffect:
					enemyPlayer.adjust_health(-1) # make this dyanmic
				enemyPlayer.adjust_health(-1) # make this dyanmic
				print("Player Host: ", isHost, " scored more")
			else:
				print("Players scored the same")
			if current_round >= max_rounds or myPlayer.getHealth() <= 0 or enemyPlayer.getHealth() <= 0:
				end_condition_reached = true
	
	#check engGame Criteria
	if end_condition_reached:
		endGame()
	else:
		network_manager.broadcast_game_state("synchronize_next_round", { "round": current_round })
		start_next_round = true

func foldEndOfRoundEffects() -> void:
	#have a tree of end of round Effects instances to pass the score through and get updated result
	
	#add logic for damage taken and other end of turn effects 
	#calculated locally based on score and totalscore
	var end_condition_reached = false
	print("WinCondition: ",win_cond)
	match win_cond:
		0: #score
			var scoreDiff = myPlayer.getLastScore() - enemyPlayer.getLastScore()
			if scoreDiff < 0:
				print("Player Host: ", isHost, " scored less")
			elif scoreDiff > 0:
				print("Player Host: ", isHost, " scored more")
			else:
				print("Players scored the same")
			#check engGame Criteria
			if current_round >= max_rounds:
				end_condition_reached = true
		1: #Health Points
			if IFolded:
				myPlayer.adjust_health(-1) # make this dyanmic
			else:
				enemyPlayer.adjust_health(-1) # make this dyanmic
			print("MyPlayer Host: ", isHost, " scored: ", myPlayer.getLastScore(), " and EnemyPlayer Host: ", !isHost, " scored: ", enemyPlayer.getLastScore(), ", I Folded: ", IFolded)
			if current_round >= max_rounds or myPlayer.getHealth() <= 0 or enemyPlayer.getHealth() <= 0:
				end_condition_reached = true
	
	#check engGame Criteria
	if end_condition_reached:
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
	#have a tree of end of game instances to check who wins/ apply effects
	
	var myPlayerStats = myPlayer.getState()
	var OpponentStats = enemyPlayer.getState()
	var myPlayerFinalStats: Dictionary
	var OpponentFinalStats: Dictionary
	var resultText = "Tied Game"
	var winner = "none"
	
	match win_cond:
		0: #score
			var scoreDiff = myPlayer.getTotalScore() - enemyPlayer.getTotalScore()
			if scoreDiff < 0:
				resultText = str(OpponentStats["player_name"], " wins the game!")
				winner = "opponent"
			elif scoreDiff > 0:
				resultText = str(myPlayerStats["player_name"], " wins the game!")
				winner = "self"
			myPlayerFinalStats = {
				"Player: ": myPlayerStats["player_name"],
				"Score: ": myPlayerStats["score"],
			}
			OpponentFinalStats = {
				"Player: ": OpponentStats["player_name"],
				"Score: ": OpponentStats["score"],
			}
		1: #Health Points
			var healthDiff = myPlayer.getHealth() - enemyPlayer.getHealth()
			if healthDiff < 0:
				resultText = str(OpponentStats["player_name"], " wins the game!")
				winner = "opponent"
			elif healthDiff > 0:
				resultText = str(myPlayerStats["player_name"], " wins the game!")
				winner = "self"
			myPlayerFinalStats = {
				"Player: ": myPlayerStats["player_name"],
				"Health Points: ": myPlayerStats["health_points"],
				"Score: ": myPlayerStats["score"],
			}
			OpponentFinalStats = {
				"Player: ": OpponentStats["player_name"],
				"Health Points: ": OpponentStats["health_points"],
				"Score: ": OpponentStats["score"],
			}
	print("Game ended")
	GameUI.hide_all_ui()
	rollButtons.visible = false
	GameUI.show_end_of_game_screen(resultText, myPlayerFinalStats, OpponentFinalStats)
	await get_tree().create_timer(5).timeout
	#Add button instead of timer
	get_parent().finish_game(winner, myPlayerFinalStats, OpponentFinalStats)

var rematch = false
func restartGame() ->void:
	network_manager.broadcast_game_state("rematch", {})
	rematch = true

func synchronizeRematch() -> void:
	print("synchronize rematch round called by Host: ", !isHost, " on Host: ", isHost)
	#wait for round to start locally
	while !(rematch):
		await get_tree().create_timer(1.0).timeout
	rematch = false
	setup_game()

func exitGame() -> void:
	network_manager.broadcast_game_state("end_game", {})
	network_manager.disconnect_from_server()
	get_parent().returnToIntro()
	pass

func timer_complete() -> void:
	exitGame()

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
		"bonus":
			recievebonus(data)
		"end_game":
			exitGame()
		"rematch":
			synchronizeRematch()
		"test":
			connectionTest(data)
		"raise":
			_raised()
		"fold":
			_folded()

func connectionTest(data: Dictionary) -> void:
	print(data)
	pass

func setup_PlayerManager(settings: Dictionary) -> void:
	myPlayer.setup_player(true, settings["health_points"],game_settings["player_names"][0] if network_manager.getIsHost() else game_settings["player_names"][1], network_manager.getIsHost(),dice_container)
	enemyPlayer.setup_player(false, settings["health_points"],game_settings["player_names"][1] if network_manager.getIsHost() else game_settings["player_names"][0], network_manager.getIsHost(),dice_container)

func setup_scoreboard(_hand_settings: Dictionary) -> void:
	#clear anything generated and re build
	scoreCalc.initializeValues()
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

func setDisableRaiseButtons(state: bool) -> void:
	if !blockRaise:
		raiseTheStakesButton.disabled = state
	foldButton.disabled = state

func blockRaiseButton(state: bool) -> void:
	blockRaise = state
	raiseTheStakesButton.disabled = state

var roll_selection_done: bool = false
var roll_selection: bool

func _on_roll_selected() -> void:
	setDisableRollButtons(true)
	network_manager.broadcast_game_state("roll_selection", { "type": "Roll" })
	roll_selection = true
	roll_selection_done = true
	if timedRounds:
			GameUI.stopTimer()
	waiting_on_other_player(true)

func _on_pass_roll() -> void:	  
	setDisableRollButtons(true)
	network_manager.broadcast_game_state("roll_selection", { "type": "Pass" })
	roll_selection = false
	roll_selection_done = true
	if timedRounds:
			GameUI.stopTimer()
	waiting_on_other_player(true)

func _on_raise() -> void:
	setDisableRaiseButtons(true)
	network_manager.broadcast_game_state("raise", { "type": "Raise" })
	raiseInEffect = true
	print("Raised")

func _raised() -> void:
	foldButton.visible = true
	raiseTheStakesButton.visible = false
	raiseInEffect = true
	print("received raise")

var IFolded = false
func _on_fold() -> void:
	setDisableRaiseButtons(true)
	network_manager.broadcast_game_state("fold", { "type": "Fold" })
	raiseInEffect = false
	print("Folded")
	IFolded = true
	foldEndOfRoundEffects()

func _folded() -> void:
	print("received fold")
	IFolded = false
	foldEndOfRoundEffects()

func resetRaise() -> void:
	raiseTheStakesButton.visible = true
	foldButton.visible = false
	raiseInEffect = false
	blockRaise = false
	IFolded = false

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
	if score[1] >= 0:
		print("Bonus Triggered")
		myPlayer.update_score(score[1])
		scoreboard.updateBonusButtonScore(score[1])
		network_manager.broadcast_game_state("bonus", { "score": score[1], "hand": hand["hand_type"] })
	myPlayer.update_score(score[0])
	scoreboard.updateButtonScore(score[0])
	hand_selection_done = true
	if timedRounds:
			GameUI.stopTimer()
	hand_selection = hand
	print(hand)
	network_manager.broadcast_game_state("hand", { "score": score[0], "hand": hand["hand_type"] })
	# Logic to proceed to next player's turn if necessary

func _on_bonus_exist(_hand: Dictionary) -> void:
	scoreCalc.setupBonus(_hand)

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
