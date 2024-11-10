extends CanvasLayer

@onready var opponent_dice_display = get_node("OpponentDiceDisplay")
@onready var game_state_info = get_node("GameStateInfo")
@onready var player_stats_panel = get_node("PlayerStatsPanel")
@onready var player_stat_box = get_node("PlayerStatsPanel/MyPlayerStatBox")
@onready var enemy_stat_box = get_node("PlayerStatsPanel/EnemyPlayerStatBox")
@onready var waiting_screen = get_node("WaitingScreen")
@onready var rollButtons = get_node("RollButtons")

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
var dice_display_height: float = 100

# Set up the UI based on the initial game settings
func setup_game_ui(game_settings: Dictionary, isHost: bool):
	#code to hide endGame and WaitingScreen
	hide_waiting_screen()
	hide_end_of_game_screen()
	if game_settings["show_rolls"]:
		show_opponent_rolls()
	else: 
		hide_opponent_rolls()
		game_state_info.position = Vector2(game_state_info.position.x, 0)
	show_roll_buttons()
	show_game_state_info()
	show_player_stats_panel()
	
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

	#opponent_dice_display.set_size(Vector2(0,container_height))
	# Initialize opponent dice display with empty sprites
	for child in opponent_dice_display.get_children():
		child.queue_free()
	for i in range(dice_count):
		var dice_sprite = preload("res://NodeScene/dice_tex_temp.tscn").instantiate()
		dice_sprite.name = "OpponentDie%d" % i
		#dice_sprite.set_texture(load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-0.png"))
		opponent_dice_display.add_child(dice_sprite)
	# Initialize player stats labels
	initialize_stat_labels(player_stat_box, "Player")
	initialize_stat_labels(enemy_stat_box, "Opponent")
	blank_opponent_dice_display()
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
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.set_texture(load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-%d.png" % rolls[i]))  # Adjust path to dice textures
			8:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-eight-faces-%d.png" % rolls[i])  # Adjust path to dice textures

# Update the opponent's dice display to blanks
func blank_opponent_dice_display():
	for i in range(dice_count):
		match dice_type:
			6:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.set_texture(load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-0.png"))  # Adjust path to dice textures
			8:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-eight-faces-0.png")  # Adjust path to dice textures


# Function to update the width of the HBoxContainer based on the number of dice
func update_opponent_dice_display_width(dice_size: float):
	# Calculate the required width based on dice count and desired size per dice
	opponent_dice_display.size.x = dice_count * dice_size
	opponent_dice_display.size.y = dice_size

	# Center the HBoxContainer at the top middle of the screen
	opponent_dice_display.anchor_left = 0.5
	opponent_dice_display.anchor_right = 0.5
	opponent_dice_display.offset_left = -opponent_dice_display.size.x / 2
	opponent_dice_display.offset_right = opponent_dice_display.size.x / 2

	# Set vertical alignment to the top center
	opponent_dice_display.anchor_top = 0
	opponent_dice_display.anchor_bottom = 0
	opponent_dice_display.offset_top = 10  # Padding from the top of the screen
	
	opponent_dice_display.position = Vector2((DisplayServer.window_get_size().x/2.0) - opponent_dice_display.size.x,0)
	print("Position: ",opponent_dice_display.position)


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
	# Make this dynamic toread all passed keys in Dictionary
	player_stats_label.text = format_dictionary_to_string(player_stats)
	opponent_stats_label.text = format_dictionary_to_string(opponent_stats)

func format_dictionary_to_string(data: Dictionary) -> String:
	var result = ""
	for key in data.keys():
		var value = data[key]
		result += "%s: %s\n" % [str(key), str(value)]
	return result

# Hide the end of game screen
func hide_end_of_game_screen():
	end_of_game_screen.visible = false

func hide_all_ui():
	hide_roll_buttons()
	hide_opponent_rolls()
	hide_game_state_info()
	hide_player_stats_panel()
	hide_waiting_screen()
	hide_end_of_game_screen()

func hide_opponent_rolls():
	opponent_dice_display.visible = false

func show_opponent_rolls():
	opponent_dice_display.visible = true

func hide_roll_buttons():
	rollButtons.visible = false

func show_roll_buttons():
	rollButtons.visible = true

func hide_game_state_info():
	game_state_info.visible = false

func show_game_state_info():
	game_state_info.visible = true

func hide_player_stats_panel():
	player_stats_panel.visible = false

func show_player_stats_panel():
	player_stats_panel.visible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
