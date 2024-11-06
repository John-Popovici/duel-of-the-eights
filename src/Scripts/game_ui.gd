extends CanvasLayer

@onready var opponent_dice_display = get_node("OpponentDiceDisplay")
@onready var game_state_info = get_node("GameStateInfo")
@onready var player_stat_box = get_node("PlayerStatsPanel/MyPlayerStatBox")
@onready var enemy_stat_box = get_node("PlayerStatsPanel/EnemyPlayerStatBox")
@onready var waiting_screen = get_node("WaitingScreen")

@onready var end_of_game_screen = get_node("EndOfGameScreen")
@onready var winner_label = get_node("EndOfGameScreen/WinnerLabel")
@onready var player_stats_label = get_node("EndOfGameScreen/HBoxContainer/PlayerStatsLabel")
@onready var opponent_stats_label = get_node("EndOfGameScreen/HBoxContainer/OpponentStatsLabel")
@onready var restart_button = get_node("EndOfGameScreen/RestartButton")
@onready var exit_button = get_node("EndOfGameScreen/ExitButton")

var myPlayerName: String
var enemyPlayerName: String
var health_points:int
var total_rounds:int
var total_round_rolls:int
var dice_count:int
var dice_type:int

# Set up the UI based on the initial game settings
func setup_game_ui(game_settings: Dictionary, isHost: bool):
	#code to hide endGame and WaitingScreen
	hide_waiting_screen()
	hide_end_of_game_screen()
	
	if isHost:
		myPlayerName = game_settings["player_names"][0]
		enemyPlayerName = game_settings["player_names"][1]
	else:
		myPlayerName = game_settings["player_names"][1]
		enemyPlayerName = game_settings["player_names"][0]
	health_points = game_settings["health_points"]
	total_rounds = game_settings["rounds"]
	total_round_rolls = game_settings["round_rolls"]
	dice_count = game_settings["dice_count"]
	dice_type = game_settings["dice_type"]
	print("Dice Type set to: ", dice_type)
	# Initialize labels for game state
	for child in game_state_info.get_children():
		child.queue_free()
	var round_label = Label.new()
	round_label.name = "RoundLabel"
	game_state_info.add_child(round_label)
	
	var roll_label = Label.new()
	roll_label.name = "RollLabel"
	game_state_info.add_child(roll_label)
	
	# Set initial text for game state info
	update_round_info(1, total_rounds)
	update_roll_info(1, total_round_rolls)

	# Initialize opponent dice display with empty sprites
	for child in opponent_dice_display.get_children():
		child.queue_free()
	for i in range(dice_count):
		var dice_sprite = Sprite2D.new()
		dice_sprite.name = "OpponentDie%d" % i
		opponent_dice_display.add_child(dice_sprite)

	# Initialize player stats labels
	initialize_stat_labels(player_stat_box, "Player")
	initialize_stat_labels(enemy_stat_box, "Opponent")
	update_player_stats("Player", myPlayerName, health_points, 0)
	update_player_stats("Opponent", enemyPlayerName, health_points, 0)

# Helper to initialize player stat labels
func initialize_stat_labels(stat_box: VBoxContainer, player_type: String):
	for child in stat_box.get_children():
		child.queue_free()
	for stat_name in ["Name", "Health", "Score"]:
		var label = Label.new()
		label.name = "%s%sLabel" % [player_type, stat_name]
		label.text = "%s %s: " % [player_type, stat_name]
		stat_box.add_child(label)

# Update the opponent's dice display based on rolls
func update_opponent_dice_display(rolls: Array):
	for i in range(rolls.size()):
		match dice_type:
			6:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as Sprite2D
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-%d.png" % rolls[i])  # Adjust path to dice textures
			8:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as Sprite2D
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-%d.png" % rolls[i])  # Adjust path to dice textures

# Update game state info
func update_round_info(current_round: int, total_rounds: int = total_rounds):
	var round_label = game_state_info.get_node("RoundLabel") as Label
	round_label.text = "Round: %d / %d" % [current_round, total_rounds]

func update_roll_info(current_roll: int, total_rolls: int = total_round_rolls):
	var roll_label = game_state_info.get_node("RollLabel") as Label
	roll_label.text = "Roll: %d / %d" % [current_roll, total_rolls]

# Update player stats (name, health, score)
func update_player_stats(player_type: String, name: String, health: int, score: int):
	var stat_box = player_stat_box if (player_type == "Player") else enemy_stat_box
	
	stat_box.get_node("%sNameLabel" % player_type).text = "%s Name: %s" % [player_type, name]
	stat_box.get_node("%sHealthLabel" % player_type).text = "%s Health: %d" % [player_type, health]
	stat_box.get_node("%sScoreLabel" % player_type).text = "%s Score: %d" % [player_type, score]

# Show the waiting screen
func show_waiting_screen():
	waiting_screen.visible = true

# Hide the waiting screen
func hide_waiting_screen():
	waiting_screen.visible = false

# Initialize the end of game screen with winner and player stats
func show_end_of_game_screen(resultText: String, player_stats: Dictionary, opponent_stats: Dictionary):
	end_of_game_screen.visible = true
	winner_label.text = resultText
	
	var game_manager = get_parent()
	restart_button.pressed.connect(game_manager.restartGame)
	exit_button.pressed.connect(game_manager.exitGame)

	# Display player and opponent stats
	player_stats_label.text = "Player: %s\nScore: %d\nHealth: %d" % [
		player_stats["player_name"], player_stats["score"], player_stats["health_points"]
	]
	opponent_stats_label.text = "Opponent: %s\nScore: %d\nHealth: %d" % [
		opponent_stats["player_name"], opponent_stats["score"], opponent_stats["health_points"]
	]

# Hide the end of game screen
func hide_end_of_game_screen():
	end_of_game_screen.visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
