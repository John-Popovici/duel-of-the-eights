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
@onready var PausePanel = get_node("EscPanel")
@onready var EscBackground = get_node("EscBackOverlay")
@onready var ReturnToGameButton = get_node("EscPanel/EscBox/ReturnToGameButton")
@onready var ExitGameButton = get_node("EscPanel/EscBox/ExitGameButton")
@onready var SFXVolumeSlider = get_node("EscPanel/EscBox/SFXVolumeSlider")
@onready var MusicVolumeSlider = get_node("EscPanel/EscBox/MusicVolumeSlider")
@onready var AmbientVolumeSlider = get_node("EscPanel/EscBox/AmbientVolumeSlider")
@onready var timer = get_node("CountdownTimer")
@onready var countdownBar = get_node("CountdownPanel/ProgressBar")
@onready var countdownPanel = get_node("CountdownPanel")

@onready var end_of_game_screen = get_node("EndOfGameScreen")
@onready var winner_label = get_node("EndOfGameScreen/WinnerLabel")
@onready var player_stats_label = get_node("EndOfGameScreen/HBoxContainer/PlayerStatsLabel")
@onready var opponent_stats_label = get_node("EndOfGameScreen/HBoxContainer/OpponentStatsLabel")
@onready var restart_button = get_node("EndOfGameScreen/RestartButton")
@onready var exit_button = get_node("EndOfGameScreen/ExitButton")
@onready var sort_asc_button = get_node("MyPlayerDiceBase/RollSorter/ButtonHolder/Asc")
@onready var sort_desc_button = get_node("MyPlayerDiceBase/RollSorter/ButtonHolder/Desc")
@onready var sort_freq_button = get_node("MyPlayerDiceBase/RollSorter/ButtonHolder/Freq")
@onready var chatUI = get_node("ChatUI")
var chatEnabled = false

var myPlayerName: String
var myPlayerDice
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
	if game_settings["timed_rounds"]: #change to setting info
		show_countdown_panel()
	else:
		hide_countdown_panel()
	
	chatEnabled = GlobalSettings.profile_settings["chat_enabled"]
	show_chat_ui()
	
	show_game_state_info()
	show_player_stats_panel()
	show_my_player_rolls()
	show_camera_options()
	
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
	# Initialize labels for game state
	for child in game_state_info.get_children():
		child.free()
		
	var round_label = Label.new()
	round_label.name = "RoundLabel"
	game_state_info.add_child(round_label)
	Debugger.log(str("Label made on Host: ", isHost))
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
	var playerDict = {
		"Name": myPlayerName,
		"Health": health_points,
		"Score": 0
	}
	update_player_stats("Player", playerDict) #make more dynamic
	var opponentDict = {
		"Name": enemyPlayerName,
		"Health": health_points,
		"Score": 0
	}
	update_player_stats("Opponent", opponentDict) #make more dynamic
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
			4:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-eight-faces-%d.png" % rolls[i])  # Adjust path to dice textures
			12:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/12 Sided/dice-twelve-faces-%d.png" % rolls[i])  # Adjust path to dice textures

func update_my_player_dice_display(_dice: Array[RigidBody3D]):
	if _dice == null:
		return
	myPlayerDice = sortDice(_dice,sortMethod)
	for i in range(myPlayerDice.size()):
		var face_value = myPlayerDice[i].get_face_value()
		match dice_type:
			6:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				var _norm_tex = load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-six-faces-%d.png" % face_value)
				var _selected_tex = load("res://Assets/2D Assets/DiceSprites/6 Sided/dice-selected-six-faces-%d.png" % face_value)
				dice_sprite.setDie(myPlayerDice[i],_norm_tex,_selected_tex)
			8:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				var _norm_tex = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-eight-faces-%d.png" % face_value)
				var _selected_tex = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-selected-eight-faces-%d.png" % face_value)
				dice_sprite.setDie(myPlayerDice[i],_norm_tex,_selected_tex)
			4:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				var _norm_tex = load("res://Assets/2D Assets/DiceSprites/4 Sided/dice-four-faces-%d.png" % face_value)
				var _selected_tex = load("res://Assets/2D Assets/DiceSprites/4 Sided/dice-selected-four-faces-%d.png" % face_value)
				dice_sprite.setDie(myPlayerDice[i],_norm_tex,_selected_tex)
			12:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				var _norm_tex = load("res://Assets/2D Assets/DiceSprites/12 Sided/dice-twelve-faces-%d.png" % face_value)
				var _selected_tex = load("res://Assets/2D Assets/DiceSprites/12 Sided/dice-selected-twelve-faces-%d.png" % face_value)
				dice_sprite.setDie(myPlayerDice[i],_norm_tex,_selected_tex)

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
	Debugger.log(str(frequency_dict))
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
			4:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-eight-faces-0.png")  # Adjust path to dice textures
			12:
				var dice_sprite = opponent_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/12 Sided/dice-twelve-faces-0.png")  # Adjust path to dice textures

func blank_my_player_dice_display():
	myPlayerDice = null
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
			4:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.clearDie()
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/8 Sided/dice-eight-faces-0.png")  # Adjust path to dice textures
			12:
				var dice_sprite = my_player_dice_display.get_node("OpponentDie%d" % i) as TextureRect
				dice_sprite.clearDie()
				dice_sprite.texture = load("res://Assets/2D Assets/DiceSprites/12 Sided/dice-twelve-faces-0.png")  # Adjust path to dice textures


# Update game state info
func update_round_info(current_round: int, _total_rounds: int = total_rounds):
	var round_label = game_state_info.get_node("RoundLabel") as Label
	Debugger.log(str(game_state_info.get_children()))
	Debugger.log(str("Round Label ID: ",round_label, " on Host: ", isHost))
	round_label.text = "Round: %d / %d" % [current_round, _total_rounds]

func update_roll_info(current_roll: int, total_rolls: int = total_round_rolls):
	var roll_label = game_state_info.get_node("RollLabel") as Label
	roll_label.text = "Roll: %d / %d" % [current_roll, total_rolls]

# Update player stats (name, health, score)
func update_player_stats(player_type: String, _player_info: Dictionary):
	var stat_box = player_stat_box if (player_type == "Player") else enemy_stat_box
	
	# Clear existing children in stat_box
	for child in stat_box.get_children():
		child.queue_free()
	# Create labels dynamically for each key-value pair in the dictionary
	for key in _player_info.keys():
		var value = _player_info[key]
		var label = Label.new()
		label.text = "%s: %s" % [key.capitalize(), str(value)]
		stat_box.add_child(label)

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
	
	hide_chat_ui()
	
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
	show_chat_ui()

func hide_all_ui():
	hide_opponent_rolls()
	hide_my_player_rolls()
	hide_game_state_info()
	hide_player_stats_panel()
	hide_waiting_screen()
	hide_end_of_game_screen()
	hide_pause_menu()
	hide_camera_options()
	hide_countdown_panel()
	hide_chat_ui()

func hide_camera_options() -> void:
	get_parent().get_node("CameraController").set_options_visible(false)

func show_camera_options() -> void:
	get_parent().get_node("CameraController").set_options_visible(true)

func hide_pause_menu():
	PausePanel.visible = false
	EscBackground.visible = false

func show_pause_menu():
	if escScreenAllowed:
		PausePanel.visible = true
		EscBackground.visible = true

func hide_chat_ui():
	chatUI.visible = false

func show_chat_ui():
	if chatEnabled:
		chatUI.visible = true
	else:
		chatUI.visible = false

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


func hide_game_state_info():
	game_state_panel.visible = false

func show_game_state_info():
	game_state_panel.visible = true

func hide_player_stats_panel():
	player_stats_panel.visible = false

func hide_countdown_panel():
	countdownPanel.visible = false

func show_countdown_panel():
	countdownPanel.visible = true

func show_player_stats_panel():
	player_stats_panel.visible = true

func _on_asc_sort_pressed():
	sortMethod = 1
	if myPlayerDice == null:
		return
	update_my_player_dice_display(myPlayerDice)

func _on_desc_sort_pressed():
	sortMethod = 2
	if myPlayerDice == null:
		return
	update_my_player_dice_display(myPlayerDice)

func _on_freq_sort_pressed():
	sortMethod = 3
	if myPlayerDice == null:
		return
	update_my_player_dice_display(myPlayerDice)

var startTime: float
var currentDuration: float
var continueCountdown: bool = false
func startTimer(_duration: int) -> void:
	startTime = float(_duration)
	currentDuration = float(_duration)
	timer.set_wait_time(startTime)
	timer.connect("timeout",get_parent().timer_complete)
	timer.start()
	continueCountdown = true
	

func stopTimer() -> void:
	timer.disconnect("timeout",get_parent().timer_complete)
	continueCountdown = false
	timer.stop()
	countdownBar.set_value(100)

func pauseTimer() -> void:
	if timer.is_stopped():
		return
	currentDuration = timer.time_left
	continueCountdown = false
	timer.stop()

func playTimer() -> void:
	if currentDuration > 0:
		timer.wait_time = currentDuration
		timer.start()
		continueCountdown = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	ReturnToGameButton.connect("pressed",self.hide_pause_menu)
	var game_manager = get_parent()
	ExitGameButton.pressed.connect(game_manager.exitGame)
	sort_asc_button.pressed.connect(_on_asc_sort_pressed)
	sort_desc_button.pressed.connect(_on_desc_sort_pressed)
	sort_freq_button.pressed.connect(_on_freq_sort_pressed)
	game_manager.connect("update_player_stats", self.update_player_stats)
	SFXVolumeSlider.value = int(AudioManager.get_sfx_volume()*100)
	MusicVolumeSlider.value = int(AudioManager.get_music_volume()*100)
	AmbientVolumeSlider.value = int(AudioManager.get_ambience_volume()*100)
	SFXVolumeSlider.value_changed.connect(change_sfx_vol)
	MusicVolumeSlider.value_changed.connect(change_music_vol)
	AmbientVolumeSlider.value_changed.connect(change_ambient_vol)

func change_sfx_vol(_val: float)-> void:
	AudioManager.set_sfx_volume(_val/100)
	Debugger.log(str("Vol set to: ",_val))

func change_music_vol(_val: float)-> void:
	AudioManager.set_music_volume(_val/100)
	Debugger.log(str("Vol set to: ",_val))
	
func change_ambient_vol(_val: float)-> void:
	AudioManager.set_ambience_volume(_val/100)
	Debugger.log(str("Vol set to: ",_val))


var warning_threshold = 0.4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if continueCountdown: #loop break/start var
		countdownBar.set_value(ceil(timer.get_time_left()/startTime*100))
		if timer.time_left <= startTime * warning_threshold:
			play_heartbeat()
		else:
			stop_heartbeat()
	else:
		stop_heartbeat()

var heartbeat_active = false

func play_heartbeat():
	if heartbeat_active:
		return
	heartbeat_active = true
	while heartbeat_active:
		AudioManager.play_sfx("Heartbeat")
		await get_tree().create_timer(4).timeout


func stop_heartbeat():
	heartbeat_active = false
