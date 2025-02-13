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
@onready var cameraController = get_node("CameraController")
@onready var cameraGameLocation = get_node("CameraController/Positions/Angled")
@onready var cameraCinematicLocation = get_node("CameraController/Positions/Cinematic")

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
var raiseContinued: bool = false
var blockRaise: bool
var invertSelection: bool = false

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
	AudioManager.play_music("gameplay")
	AudioManager.connect_buttons()
	invertSelection = GlobalSettings.profile_settings.get("invert_selection_method")

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
	setup_scoreboard(game_settings,hand_settings)
	setup_PlayerManager(game_settings)
	Debugger.log(str("Setup UI Called on Host: ", network_manager.getIsHost()))
	GameUI.setup_game_ui(game_settings,network_manager.getIsHost())
	rollButtons.visible = true
	Debugger.log(str("Setup UI Finished Calling Called on Host: ", network_manager.getIsHost()))
	isHost = network_manager.getIsHost()
	network_manager.connect("game_state_received", self._on_game_state_received)
	rollSelected.connect("pressed", self._on_roll_selected)
	if invertSelection:
		rollSelected.text = "Keep Selected"
	passRoll.connect("pressed", self._on_pass_roll)
	raiseTheStakesButton.connect("pressed", self._on_raise)
	foldButton.connect("pressed", self._on_fold)
	setDisableAllButtons(true)
	GameUI.visible = true
	GameUI.hide_waiting_screen()
	current_round = 0
	max_rolls_per_round = game_settings["round_rolls"]
	max_rounds = game_settings["rounds"]
	Debugger.log("bluffMechanicActive: " + str(bluffMechanicActive))
	if bluffMechanicActive:
		BluffButtons.visible = true
		raiseTheStakesButton.visible = true
		foldButton.visible = false
		raiseInEffect = false
		raiseContinued = false
		blockRaise = false
		setDisableRaiseButtons(true)
	else:
		BluffButtons.visible = false
	Debugger.log(str("Setup Game Done on Host: ", isHost))
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
		Debugger.log("Host Started Round")
		network_manager.broadcast_game_state("round_start", { "round": current_round })
		await get_tree().create_timer(1.0).timeout
	else:
		Debugger.log("Client Started Round")
		await get_tree().create_timer(1.0).timeout
	network_manager.broadcast_game_state("synchronize_start_round", { "round": current_round })
	await get_tree().create_timer(0.1).timeout  # Short delay to ensure propagation
	myPlayerRoundStarted()

var otherPlayerRoundStarted = false

func synchronizeStartRound() -> void:
	Debugger.log(str("synchronize start round called by Host: ", !isHost, " on Host: ", isHost))
	otherPlayerRoundStarted = true
	#start rolls phase
	if otherPlayerRoundStarted and round_start_done:
		round_start_done = false
		otherPlayerRoundStarted = false
		rollPhase(true)

func myPlayerRoundStarted() -> void:
	round_start_done = true
	if otherPlayerRoundStarted and round_start_done:
		round_start_done = false
		otherPlayerRoundStarted = false
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
		if raiseInEffect:
			raiseContinued = true
		if invertSelection:
			myPlayer.invert_selection()
			await get_tree().create_timer(0.5).timeout
		myPlayer.roll_selected_dice()
	elif !roll:
		if raiseInEffect:
			raiseContinued = true
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
	if !raiseContinued:
		GameUI.update_opponent_dice_display(_rolls)
	else:
		GameUI.blank_opponent_dice_display()
	Debugger.log(str("Received enemy rolls ", _rolls, " from Host: ", fromHost))
	other_players_rolls_read = true
	if other_players_rolls_read and rolls_read:
		GameUI.update_my_player_dice_display(myPlayer.get_dice())
		rolls_read = false
		other_players_rolls_read = false
		await get_tree().create_timer(1.0).timeout
		waiting_on_other_player(false)
		setup_selection()

var rolls_read: bool = false
var other_players_rolls_read: bool = false

func set_rolls_read(state: bool) ->void:
	rolls_read = state
	if other_players_rolls_read and rolls_read:
		GameUI.update_my_player_dice_display(myPlayer.get_dice())
		rolls_read = false
		other_players_rolls_read = false
		await get_tree().create_timer(1.0).timeout
		waiting_on_other_player(false)
		setup_selection()

func setup_selection() -> void:
	if GlobalSettings.profile_settings["align_rolled_dice"]:
			myPlayer.move_dice_inline()
	myPlayer.toggle_dice_collisions(false)
	if roll_count >= max_rolls_per_round:
		hand_selection_done = false
		Debugger.log(str("Host: ", isHost, " reached hand selection on roll_count: ", roll_count, " of max: ", max_rolls_per_round))
		setDisableScoreBoardButtons(false)
		if timedRounds:
			GameUI.startTimer(baseTimer*2)
	else:
		roll_selection_done = false
		other_player_roll_selection = false
		Debugger.log(str("Host: ", isHost, " reached roll selection on roll_count: ", roll_count, " of max: ", max_rolls_per_round))
		setDisableRollButtons(false)
		if timedRounds:
			GameUI.startTimer(baseTimer)

var other_player_roll_selection = false

func recieveRollSelection(_type: String) -> void:
	other_player_roll_selection = true
	#wait on roll selection locally
	if other_player_roll_selection and roll_selection_done:
		roll_selection_done = false
		other_player_roll_selection = false
		waiting_on_other_player(false)
		rollPhase(roll_selection)

var other_player_hand_selection_done = false

func recievehand(hand: Dictionary) -> void:
	enemyPlayer.update_score(hand["score"])
	other_player_hand_selection_done = true
	#add code to enemy player to log all hands in order with score
	if hand_selection_done and other_player_hand_selection_done:
		hand_selection_done = false
		other_player_hand_selection_done = false
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
	Debugger.log(str("WinCondition: ",win_cond))
	match win_cond:
		0: #score
			var scoreDiff = myPlayer.getLastScore() - enemyPlayer.getLastScore()
			if scoreDiff < 0:
				Debugger.log(str("Player Host: ", isHost, " scored less"))
			elif scoreDiff > 0:
				Debugger.log(str("Player Host: ", isHost, " scored more"))
			else:
				Debugger.log("Players scored the same")
			#check engGame Criteria
			if current_round >= max_rounds:
				end_condition_reached = true
		1: #Health Points
			var scoreDiff = myPlayer.getLastScore() - enemyPlayer.getLastScore()
			Debugger.log(str("MyPlayer Host: ", isHost, " scored: ", myPlayer.getLastScore(), " and EnemyPlayer Host: ", !isHost, " scored: ", enemyPlayer.getLastScore()))
			if scoreDiff < 0:
				if raiseInEffect:
					myPlayer.adjust_health(-1) # make this dyanmic
				myPlayer.adjust_health(-1) # make this dyanmic
				Debugger.log(str("Player Host: ", isHost, "scored less, took damage"))
			elif scoreDiff > 0:
				if raiseInEffect:
					enemyPlayer.adjust_health(-1) # make this dyanmic
				enemyPlayer.adjust_health(-1) # make this dyanmic
				Debugger.log(str("Player Host: ", isHost, " scored more"))
			else:
				Debugger.log("Players scored the same")
			if current_round >= max_rounds or myPlayer.getHealth() <= 0 or enemyPlayer.getHealth() <= 0:
				end_condition_reached = true
	
	#check engGame Criteria
	if end_condition_reached:
		endGame()
	else:
		network_manager.broadcast_game_state("synchronize_next_round", { "round": current_round })
		start_next_round = true
		if start_next_round and other_player_start_next_round:
			start_next_round = false
			other_player_start_next_round = false
			if(isHost):
				start_round()

func foldEndOfRoundEffects() -> void:
	#have a tree of end of round Effects instances to pass the score through and get updated result
	
	#add logic for damage taken and other end of turn effects 
	#calculated locally based on score and totalscore
	var end_condition_reached = false
	Debugger.log(str("WinCondition: ",win_cond))
	match win_cond:
		0: #score
			var scoreDiff = myPlayer.getLastScore() - enemyPlayer.getLastScore()
			if scoreDiff < 0:
				Debugger.log(str("Player Host: ", isHost, " scored less"))
			elif scoreDiff > 0:
				Debugger.log(str("Player Host: ", isHost, " scored more"))
			else:
				Debugger.log("Players scored the same")
			#check engGame Criteria
			if current_round >= max_rounds:
				end_condition_reached = true
		1: #Health Points
			if IFolded:
				myPlayer.adjust_health(-1) # make this dyanmic
			else:
				enemyPlayer.adjust_health(-1) # make this dyanmic
			Debugger.log(str("MyPlayer Host: ", isHost, " scored: ", myPlayer.getLastScore(), " and EnemyPlayer Host: ", !isHost, " scored: ", enemyPlayer.getLastScore(), ", I Folded: ", IFolded))
			if current_round >= max_rounds or myPlayer.getHealth() <= 0 or enemyPlayer.getHealth() <= 0:
				end_condition_reached = true
	
	#check engGame Criteria
	if end_condition_reached:
		endGame()
	else:
		network_manager.broadcast_game_state("synchronize_next_round", { "round": current_round })
		start_next_round = true
		if start_next_round and other_player_start_next_round:
			start_next_round = false
			other_player_start_next_round = false
			if(isHost):
				start_round()

var start_next_round = false
var other_player_start_next_round = false

func synchronizeNextRound() -> void:
	Debugger.log(str("synchronize next round called by Host: ", !isHost, " on Host: ", isHost))
	other_player_start_next_round = true
	if start_next_round and other_player_start_next_round:
		start_next_round = false
		other_player_start_next_round = false
		if(isHost):
			start_round()

func endGame() -> void:
	#have a tree of end of game instances to check who wins/ apply effects
	cameraController.lerp_camera_to_position(cameraCinematicLocation, 0.01)
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
	Debugger.log("Game ended")
	GameUI.hide_all_ui()
	rollButtons.visible = false
	if winner == "none" or winner =="self":
		AudioManager.play_sfx("win_sound")
	else:
		AudioManager.play_sfx("lose_sound")
	GameUI.show_end_of_game_screen(resultText, myPlayerFinalStats, OpponentFinalStats)

var rematch = false
func restartGame() ->void:
	network_manager.broadcast_game_state("rematch", {})
	rematch = true
	if rematch and other_player_rematch:
		rematch = false
		other_player_rematch = false
		setup_game()

var other_player_rematch = false
func synchronizeRematch() -> void:
	Debugger.log(str("synchronize rematch round called by Host: ", !isHost, " on Host: ", isHost))
	other_player_rematch = true
	if rematch and other_player_rematch:
		rematch = false
		other_player_rematch = false
		setup_game()

func exitGame() -> void:
	network_manager.broadcast_game_state("end_game", {})
	network_manager.disconnect_from_server()
	SceneSwitcher.returnToIntro()
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
	Debugger.log(str(data))
	pass

func setup_PlayerManager(settings: Dictionary) -> void:
	myPlayer.setup_player(true, settings["health_points"],game_settings["player_names"][0] if network_manager.getIsHost() else game_settings["player_names"][1], network_manager.getIsHost(),dice_container)
	enemyPlayer.setup_player(false, settings["health_points"],game_settings["player_names"][1] if network_manager.getIsHost() else game_settings["player_names"][0], network_manager.getIsHost(),dice_container)

func setup_scoreboard(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	#clear anything generated and re build
	scoreCalc.initializeValues(_game_settings)
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
	if raiseInEffect:
		raiseTheStakesButton.disabled = true
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
	if other_player_roll_selection and roll_selection_done:
		roll_selection_done = false
		other_player_roll_selection = false
		waiting_on_other_player(false)
		rollPhase(roll_selection)

func _on_pass_roll() -> void:	  
	setDisableRollButtons(true)
	network_manager.broadcast_game_state("roll_selection", { "type": "Pass" })
	roll_selection = false
	roll_selection_done = true
	if timedRounds:
			GameUI.stopTimer()
	waiting_on_other_player(true)
	if other_player_roll_selection and roll_selection_done:
		roll_selection_done = false
		other_player_roll_selection = false
		waiting_on_other_player(false)
		rollPhase(roll_selection)

func _on_raise() -> void:
	setDisableRaiseButtons(true)
	network_manager.broadcast_game_state("raise", { "type": "Raise" })
	raiseInEffect = true
	AudioManager.play_sfx("Raise")
	Debugger.log("Raised")

func _raised() -> void:
	foldButton.visible = true
	raiseTheStakesButton.visible = false
	raiseInEffect = true
	AudioManager.play_sfx("Raise")
	foldButton.get_node("AnimationPlayer").play("Raise")
	Debugger.log("received raise")

var IFolded = false
func _on_fold() -> void:
	setDisableRaiseButtons(true)
	network_manager.broadcast_game_state("fold", { "type": "Fold" })
	raiseInEffect = false
	AudioManager.play_sfx("Fold")
	Debugger.log("Folded")
	IFolded = true
	foldEndOfRoundEffects()

func _folded() -> void:
	AudioManager.play_sfx("Fold")
	Debugger.log("received fold")
	IFolded = false
	foldEndOfRoundEffects()

func resetRaise() -> void:
	raiseTheStakesButton.visible = true
	foldButton.visible = false
	raiseInEffect = false
	blockRaise = false
	IFolded = false
	raiseContinued = false

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
	Debugger.log(str(hand))
	setDisableScoreBoardButtons(true)
	var score = scoreCalc.calculate_hand_score(hand, myPlayer.getRolls())
	if score[1] >= 0:
		Debugger.log("Bonus Triggered")
		myPlayer.update_score(score[1])
		scoreboard.updateBonusButtonScore(score[1])
		network_manager.broadcast_game_state("bonus", { "score": score[1], "hand": hand["hand_type"] })
	myPlayer.update_score(score[0])
	scoreboard.updateButtonScore(score[0])
	hand_selection_done = true
	if timedRounds:
			GameUI.stopTimer()
	hand_selection = hand
	Debugger.log(str(hand))
	network_manager.broadcast_game_state("hand", { "score": score[0], "hand": hand["hand_type"] })
	# Logic to proceed to next player's turn if necessary
	if hand_selection_done and other_player_hand_selection_done:
		hand_selection_done = false
		other_player_hand_selection_done = false
		endOfRoundEffects()
		waiting_on_other_player(false)

func _on_bonus_exist(_hand: Dictionary) -> void:
	scoreCalc.setupBonus(_hand)

# Function to dynamically set up game environment based on settings
func setup_game_environment(_game_settings: Dictionary) -> void:
	# Initialize game variables and UI, create dice dynamically
	dice_container.clear_dice()
	dice_container.add_dice(_game_settings["dice_count"],int(_game_settings["dice_type"]))
	
	#add any other physical 3D setup
	cameraController.lerp_camera_to_position(cameraGameLocation, 0.01)
	
	# Additional setup can go here
	if network_manager.getIsHost():
		Debugger.log(str("Host Game Environment initialized with settings:", _game_settings))
	else:
		Debugger.log(str("Client Game Environment initialized with settings:", _game_settings))

func returnToIntro()-> void:
	SceneSwitcher.returnToIntro()
