extends CanvasLayer

@onready var opponent_dice_base = get_node("OpponentDiceBase")
@onready var opponent_dice_display = get_node("OpponentDiceBase/OpponentDicePanel/OpponentDiceDisplay")
@onready var my_player_dice_base = get_node("MyPlayerDiceBase")
@onready var my_player_dice_display = get_node("MyPlayerDiceBase/MyPlayerDicePanel/MyPlayerDiceDisplay")
@onready var game_state_panel = get_node("GameStatePanel")
@onready var game_state_info = get_node("GameStatePanel/GameStateInfo")
@onready var player_stats_panel = get_node("PlayerStatsPanel")
@onready var player_stat_box = get_node("PlayerStatsPanel/MyPlayerPanel/MyPlayerStatBox")
@onready var enemy_stat_box = get_node("PlayerStatsPanel/EnemyPlayerPanel/EnemyPlayerStatBox")
@onready var waiting_screen = get_node("WaitingScreen")
@onready var rollButtons = get_node("RollButtons")
@onready var PausePanel = get_node("EscPanel")
@onready var EscBackground = get_node("EscBackOverlay")
@onready var ReturnToGameButton = get_node("EscPanel/EscBox/ReturnToGameButton")
@onready var ExitGameButton = get_node("EscPanel/EscBox/ExitGameButton")

@onready var end_of_game_screen = get_node("EndOfGameScreen")
@onready var winner_label = get_node("EndOfGameScreen/WinnerLabel")
@onready var player_stats_label = get_node("EndOfGameScreen/HBoxContainer/PlayerStatsLabel")
@onready var opponent_stats_label = get_node("EndOfGameScreen/HBoxContainer/OpponentStatsLabel")
@onready var restart_button = get_node("EndOfGameScreen/RestartButton")
@onready var exit_button = get_node("EndOfGameScreen/ExitButton")
@onready var sort_asc_button = get_node("MyPlayerDiceBase/RollSorter/ButtonHolder/Asc")
@onready var sort_desc_button = get_node("MyPlayerDiceBase/RollSorter/ButtonHolder/Desc")
@onready var sort_freq_button = get_node("MyPlayerDiceBase/RollSorter/ButtonHolder/Freq")

var myPlayerName: String
var enemyPlayerName: String
var health_points:int
var total_rounds:int
var total_round_rolls:int
var dice_count:int
var dice_type:int
var sortMethod: int
var dice_display_height: float = 100
signal escPressed
var escScreenAllowed = false
var isHost

# Set up the UI based on the initial game settings
func setup_game_ui(game_settings: Dictionary, _isHost: bool):
	#code to hide endGame and WaitingScreen
	isHost = _isHost
	escScreenAllowed = true
	hide_waiting_screen()
	hide_end_of_game_screen()
	hide_pause_menu()
	if game_settings["show_rolls"]:
		show_opponent_rolls()
	else: 
		hide_opponent_rolls()
	show_roll_buttons()
	show_game_state_info()
	show_player_stats_panel()
	show_my_player_rolls()
	
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
	sortMethod = 1
	print("Dice Type set to: ", dice_type)
	# Initialize labels for game state
	for child in game_state_info.get_children():
		child.free()
		
	var round_label = Label.new()
	round_label.name = "RoundLabel"
	game_state_info.add_child(round_label)
	print("Label made on Host: ", isHost)
	var roll_label = Label.new()
	roll_label.name = "RollLabel"
	game_state_info.add_child(roll_label)
	
	# Set initial text for game state info
	update_round_info(1, total_rounds)
	update_roll_info(1, total_round_rolls)

	# Initialize dice displays with empty sprites
	initialize_opponent_dice_display()
	initialize_my_player_dice_display()
	# Initialize player stats labels
	initialize_stat_labels(player_stat_box, "Player") #make more dynamic
	initialize_stat_labels(enemy_stat_box, "Opponent") #make more dynamic
	update_player_stats("Player", myPlayerName, health_points, 0) #make more dynamic
	update_player_stats("Opponent", enemyPlayerName, health_points, 0) #make more dynamic
	connect("escPressed",self.toggle_pause_menu)

# Helper to initialize player stat labels
func initialize_stat_labels(stat_box: VBoxContainer, player_type: String):
	for child in stat_box.get_children():
		child.free()
	for stat_name in ["Name", "Health", "Score"]:
		var label = Label.new()
		label.name = "%s%sLabel" % [player_type, stat_name]
		label.text = "%s %s: " % [player_type, stat_name]
		stat_box.add_child(label)

func initialize_opponent_dice_display() -> void:
	# Initialize opponent dice display with empty sprites
	for child in opponent_dice_display.get_children():
		child.free()
	for i in range(dice_count):
		var dice_sprite = preload("res://NodeScene/dice_tex_temp.tscn").instantiate()
		dice_sprite.name = "OpponentDie%d" % i
		#dice_sprite.set_texture(load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-0.png"))
		opponent_dice_display.add_child(dice_sprite)
	blank_opponent_dice_display()

func initialize_my_player_dice_display() -> void:
	# Initialize my dice display with empty sprites
	for child in my_player_dice_display.get_children():
		child.free()
	for i in range(dice_count):
		var dice_sprite = preload("res://NodeScene/dice_tex_temp.tscn").instantiate()
		dice_sprite.name = "OpponentDie%d" % i
		#dice_sprite.set_texture(load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-0.png"))
		my_player_dice_display.add_child(dice_sprite)
	blank_my_player_dice_display()

# Update the opponent's dice display based on rolls
func update_opponent_dice_display(rolls: Array):
	rolls.sort()
	for i in range(rolls.size()):
		match dice_type:
			6:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.set_texture(load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-%d.png" % rolls[i]))  # Adjust path to dice textures
			8:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-eight-faces-%d.png" % rolls[i])  # Adjust path to dice textures

func update_my_player_dice_display(dice: Array[RigidBody3D]):
	dice = sortDice(dice,sortMethod)
	for i in range(dice.size()):
		var face_value = dice[i].get_face_value()
		match dice_type:
			6:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.setDie(dice[i])
				dice_sprite.set_texture(load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-%d.png" % face_value))  # Adjust path to dice textures
			8:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.setDie(dice[i])
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-eight-faces-%d.png" % face_value)  # Adjust path to dice textures

func sortDice(_dice: Array[RigidBody3D], _sortMethod: int = 1)-> Array[RigidBody3D]:
	match _sortMethod:
		1:
			_dice.sort_custom(custom_sort_ascending)
		2:
			_dice.sort_custom(custom_sort_descending)
		3:
			_dice = sort_by_frequency(_dice)
	return _dice

func custom_sort_ascending(a, b):
	if a.get_face_value() < b.get_face_value():
		return true
	return false

func custom_sort_descending(a, b):
	if a.get_face_value() > b.get_face_value():
		return true
	return false

var frequency_dict = {}

func sort_by_frequency(_dice: Array[RigidBody3D]) -> Array[RigidBody3D]:
	frequency_dict.clear()
	
	# Calculate the frequency of each element in the array
	for die in _dice:
		var faceValue = die.get_face_value()
		if faceValue in frequency_dict:
			frequency_dict[faceValue] += 1
		else:
			frequency_dict[faceValue] = 1
	print(frequency_dict)
	# Sort the array by frequency (descending), and by value (ascending) if frequencies are equal
	_dice.sort_custom(_compare_by_frequency)

	return _dice

# Custom comparator function for sorting based on frequency and value
func _compare_by_frequency(a, b) -> int:
	var freq_a = frequency_dict[a.get_face_value()]
	var freq_b = frequency_dict[b.get_face_value()]
	
	# Compare by frequency in descending order
	if freq_a != freq_b:
		return freq_b < freq_a
	# If frequencies are equal, compare by value in ascending order
	return a.get_face_value() < b.get_face_value()


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

func blank_my_player_dice_display():
	for i in range(dice_count):
		match dice_type:
			6:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.clearDie()
				dice_sprite.set_texture(load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-0.png"))  # Adjust path to dice textures
			8:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.clearDie()
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-eight-faces-0.png")  # Adjust path to dice textures


# Update game state info
func update_round_info(current_round: int, _total_rounds: int = total_rounds):
	var round_label = game_state_info.get_node("RoundLabel") as Label
	print(game_state_info.get_children())
	print("Round Label ID: ",round_label, " on Host: ", isHost)
	round_label.text = "Round: %d / %d" % [current_round, _total_rounds]

func update_roll_info(current_roll: int, total_rolls: int = total_round_rolls):
	var roll_label = game_state_info.get_node("RollLabel") as Label
	roll_label.text = "Roll: %d / %d" % [current_roll, total_rolls]

# Update player stats (name, health, score)
func update_player_stats(player_type: String, _name: String, health: int, score: int):
	var stat_box = player_stat_box if (player_type == "Player") else enemy_stat_box
	
	stat_box.get_node("%sNameLabel" % player_type).text = "%s Name: %s" % [player_type, _name]
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
	EscBackground.visible = true
	escScreenAllowed = false
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
	EscBackground.visible = false
	escScreenAllowed = true

func hide_all_ui():
	hide_roll_buttons()
	hide_opponent_rolls()
	hide_my_player_rolls()
	hide_game_state_info()
	hide_player_stats_panel()
	hide_waiting_screen()
	hide_end_of_game_screen()
	hide_pause_menu()

func hide_pause_menu():
	PausePanel.visible = false
	EscBackground.visible = false

func show_pause_menu():
	if escScreenAllowed:
		PausePanel.visible = true
		EscBackground.visible = true

func toggle_pause_menu():
	if PausePanel.visible:
		hide_pause_menu()
	else:
		show_pause_menu()

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_ESCAPE :
			escPressed.emit()

func hide_opponent_rolls():
	opponent_dice_base.visible = false

func show_opponent_rolls():
	opponent_dice_base.visible = true

func hide_my_player_rolls():
	my_player_dice_base.visible = false

func show_my_player_rolls():
	my_player_dice_base.visible = true

func hide_roll_buttons():
	rollButtons.visible = false

func show_roll_buttons():
	rollButtons.visible = true

func hide_game_state_info():
	game_state_panel.visible = false

func show_game_state_info():
	game_state_panel.visible = true

func hide_player_stats_panel():
	player_stats_panel.visible = false

func show_player_stats_panel():
	player_stats_panel.visible = true

func _on_asc_sort_pressed():
	sortMethod = 1
	update_my_player_dice_display(get_parent().get_node("myPlayer").get_dice())

func _on_desc_sort_pressed():
	sortMethod = 2
	update_my_player_dice_display(get_parent().get_node("myPlayer").get_dice())

func _on_freq_sort_pressed():
	sortMethod = 3
	update_my_player_dice_display(get_parent().get_node("myPlayer").get_dice())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	ReturnToGameButton.connect("pressed",self.hide_pause_menu)
	var game_manager = get_parent()
	ExitGameButton.pressed.connect(game_manager.exitGame)
	sort_asc_button.pressed.connect(_on_asc_sort_pressed)
	sort_desc_button.pressed.connect(_on_desc_sort_pressed)
	sort_freq_button.pressed.connect(_on_freq_sort_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
