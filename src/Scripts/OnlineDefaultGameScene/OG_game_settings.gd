extends CanvasLayer

signal game_settings_ready(game_settings,hand_settings)
@onready var settingsSetup = get_node("UIBox/SettingsSplitBox/Settings_Setup")
@onready var settingsAdvanced = get_node("UIBox/Settings_Advanced")
@onready var settingsWait = get_node("UIBox/Settings_Wait")
@onready var start_game_button = settingsSetup.get_node("Buttons/StartGame")
@onready var copy_connect_code_button = settingsSetup.get_node("Buttons/CopyConnectButton")
@onready var advanced_settings_button = settingsSetup.get_node("OptionsVBox/HandLimit/AdvancedSettingsButton")
@onready var return_to_settings_button = settingsAdvanced.get_node("ReturnToSettings")
@onready var save_advanced_settings_button = settingsAdvanced.get_node("SaveSettings")
@onready var home_button = settingsSetup.get_node("Buttons/BackToHomeButton")
@onready var wait_home_button = settingsWait.get_node("ExitGameButton")

@onready var player1Name = settingsSetup.get_node("OptionsVBox/PlayerNames/Player1Name")
@onready var player2Name = settingsSetup.get_node("OptionsVBox/PlayerNames/Player2Name")
@onready var WinCondition = settingsSetup.get_node("OptionsVBox/WinCondition/ConditionSelect")
@onready var HealthPoints = settingsSetup.get_node("OptionsVBox/HealthPoints/HealthPoints").get_line_edit()
@onready var HealthPointsBox = settingsSetup.get_node("OptionsVBox/HealthPoints")
@onready var BluffButton = settingsSetup.get_node("OptionsVBox/HealthPoints/BluffButton")
@onready var RoundsSpinBox = settingsSetup.get_node("OptionsVBox/Rounds/Rounds")
@onready var Rounds = settingsSetup.get_node("OptionsVBox/Rounds/Rounds").get_line_edit()
@onready var RoundRolls = settingsSetup.get_node("OptionsVBox/Rounds/RoundRolls").get_line_edit()
@onready var DiceCountRef = settingsSetup.get_node("OptionsVBox/Dice/DiceCount").get_line_edit()
@onready var timed_rounds_button = settingsSetup.get_node("OptionsVBox/TimedRounds/TimedRoundsToggle")
@onready var round_time = settingsSetup.get_node("OptionsVBox/TimedRounds/RoundTime").get_line_edit()
@onready var round_time_box = settingsSetup.get_node("OptionsVBox/TimedRounds/RoundTime")
@onready var DiceCountRange = settingsSetup.get_node("OptionsVBox/Dice/DiceCount")
@onready var DiceType = settingsSetup.get_node("OptionsVBox/Dice/DiceType")
@onready var opponent_roll_visible_button = settingsSetup.get_node("OptionsVBox/HandLimit/OpponentRollVisible")
@onready var advanced_settings_vbox = settingsAdvanced.get_node("ScrollContainer/advanced_settings_vbox")

@onready var presetsPanel = get_node("UIBox/SettingsSplitBox/PresetsPanelBox")
@export var presets_folder = "res://Presets"
@onready var preset_name_input = presetsPanel.get_node("NewPresetName")
@onready var save_preset_button = presetsPanel.get_node("AddPreset")
@onready var presetsButtonsBox = presetsPanel.get_node("PresetsScrollBar/PresetsButtons")

@onready var networkManagers = get_tree().get_nodes_in_group("NetworkHandlingNodes")
@onready var NetworkManager = networkManagers[0]

var hand_settings_saved = false
var hand_settings_loaded = false
@export var hand_settings_refs: Dictionary = {}
@export var hand_settings_vals: Dictionary = {}:
	set(value):
		hand_settings_vals = value
		_hand_settings_vals_changed()
@export var game_settings: Dictionary = {}

var total_playable_hands: int
# Capture the dice type and count
var dice_count: int
var dice_type: int
var win_cond: String
var show_opponent_rolls: bool = false
var timed_rounds: bool = true
var bluff_active: bool = false

const YAHTZEE_MAX_PLAYS: int = 5

func _on_start_game_pressed():
	start_game_button.disabled = true
	home_button.disabled = true
	advanced_settings_button.disabled = true
	Debugger.log("Win Condition: " + str(WinCondition.get_selected_id()))
	if WinCondition.get_selected_id() == 0:
		bluff_active = false
	game_settings = {
		"player_names": [player1Name.text, player2Name.text],
		"win_condition": WinCondition.get_selected_id(),
		"health_points": int(HealthPoints.text),
		"rounds": int(Rounds.text),
		"round_rolls": int(RoundRolls.text),
		"dice_count": int(DiceCountRef.text),
		"dice_type": DiceType.get_selected_id(),  # e.g., 6-sided or 8-sided
		"show_rolls": show_opponent_rolls,
		"timed_rounds": timed_rounds,
		"bluff_active": bluff_active,
		"round_time": int(round_time.text) if int(round_time.text) > 0 else 25,
	}
	if !hand_settings_saved:
		dice_count = int(DiceCountRef.text)
		dice_type = DiceType.get_selected_id()
		_populate_advanced_settings()
		await get_tree().create_timer(1.0).timeout
		save_advanced_settings()
	await get_tree().create_timer(1.0).timeout
	if calculateMaxHands() < game_settings["rounds"]:
		game_settings["rounds"] = calculateMaxHands()
	emit_signal("game_settings_ready", game_settings, hand_settings_vals)
	self.visible = false

func _win_condition_toggled(ID):
	Debugger.log(str("Win Condition Toggled: ", int(ID)))
	var win_cond_num = int(ID)
	match win_cond_num:
		0: #score
			HealthPointsBox.visible = false
			win_cond = "Score"
			bluff_active = false
			BluffButton.set_pressed(false)
			Debugger.log("Score Condition")
		1: #healthpoints
			HealthPointsBox.visible = true
			win_cond = "Health"
			Debugger.log("Health Condition")

func _on_advanced_settings_pressed() -> void:
	dice_count = int(DiceCountRef.text)
	dice_type = DiceType.get_selected_id()
	settingsSetup.visible = false
	presetsPanel.visible = false
	if !hand_settings_saved or !hand_settings_loaded:
		_populate_advanced_settings()
	settingsAdvanced.visible = true

# Populates the advanced settings based on dice count and type
func _populate_advanced_settings():
	# Clear current advanced settings to rebuild them
	hand_settings_refs.clear()
	hand_settings_vals.clear()
	for child in advanced_settings_vbox.get_children():
		child.queue_free()

	# Generate and add each hand to the VBoxContainer
	advanced_settings_vbox.add_child(_create_label("Single Numbers"))
	_generate_singles()
	
	advanced_settings_vbox.add_child(_create_label("Bonus"))
	_generate_bonus()
	
	advanced_settings_vbox.add_child(_create_label("Straights"))
	_generate_straights()
	
	advanced_settings_vbox.add_child(_create_label("Kinds"))
	_generate_kinds()
	
	advanced_settings_vbox.add_child(_create_label("Full Houses"))
	_generate_full_houses()
	
	advanced_settings_vbox.add_child(_create_label("All in"))
	_generate_chance()
	
	hand_settings_loaded = true

func calculateMaxHands() -> int:
	var maxHands = 0
	for hand_name in hand_settings_vals.keys():
		var settings = hand_settings_vals[hand_name]
		if hand_name != "Bonus" and settings["allowed"]:
			if settings["repeatable"]:
				maxHands += settings["max_plays"]
			else:
				maxHands += 1
	Debugger.log(str("Max Hands on Calculation: ", maxHands))
	return maxHands

# Save a new preset with game and hand settings
func save_preset():
	var preset_name = preset_name_input.text.strip_edges()
	preset_name_input.text = ""
	Debugger.log(str("Preset Name from input: ", preset_name))
	if preset_name == "":
		Debugger.log("Please enter a name for the preset.")
		return
	Debugger.log("Storing Settings into Variables")
	game_settings = {
		"player_names": [player1Name.text, player2Name.text],
		"win_condition": WinCondition.get_selected_id(),
		"health_points": int(HealthPoints.text),
		"rounds": int(Rounds.text),
		"round_rolls": int(RoundRolls.text),
		"dice_count": int(DiceCountRef.text),
		"dice_type": DiceType.get_selected_id(),  # e.g., 6-sided or 8-sided
		"show_rolls": show_opponent_rolls,
		"timed_rounds": timed_rounds,
		"bluff_active": bluff_active,
		"round_time": int(round_time.text) if int(round_time.text) > 0 else 25,
	}
	
	if !hand_settings_saved:
		dice_count = int(DiceCountRef.text)
		dice_type = DiceType.get_selected_id()
		_populate_advanced_settings()
		await get_tree().create_timer(1.0).timeout
		save_advanced_settings()
		await get_tree().create_timer(1.0).timeout

	var preset_data = {
		"preset_name": preset_name,
		"game_settings": game_settings,
		"hand_settings": hand_settings_vals
	}

	var file_path = presets_folder + "/" + preset_name + ".json"
	Debugger.log(str("Writing to: ", file_path))
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var json = JSON.new()
	var json_string = json.stringify(preset_data)
	file.store_string(json_string)
	file.close()
	Debugger.log(str("Preset saved:", preset_name))
	load_preset_buttons()  # Refresh preset buttons

# Load existing presets and populate buttons
func load_preset_buttons():
	for child in presetsButtonsBox.get_children():# Clear existing entries
		child.queue_free()
	var dir = DirAccess.open(presets_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var preset_name = file_name.replace(".json", "")
				var button = load("res://NodeScene/sample_preset_button.tscn").instantiate()
				button.text = preset_name
				button.setSettings(preset_name)
				var select_callable = Callable(self, "_on_preset_selected")
				button.setCallable(select_callable)
				presetsButtonsBox.add_child(button)
			file_name = dir.get_next()
		dir.list_dir_end()

# Load a preset's data and apply it to the UI
func _on_preset_selected(preset_name: String):
	var file_path = presets_folder + "/" + preset_name + ".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	var preset_data = file.get_as_text()
	file.close()
	var json = JSON.new()
	json.parse(preset_data)
	game_settings = json.data.get("game_settings", {})
	hand_settings_vals = json.data.get("hand_settings", {})
	hand_settings_saved = true
	hand_settings_loaded = false
	Debugger.log(str(preset_data))
	# Update UI fields based on the loaded settings
	update_ui_fields(game_settings, hand_settings_vals)

# Update the input fields with loaded game and hand settings
func update_ui_fields(game_settings: Dictionary, hand_settings: Dictionary):
	# Example updates; adjust to fit actual input nodes in your UI
	WinCondition.select(game_settings.get("win_condition", 0))
	_win_condition_toggled(game_settings.get("win_condition", 0))
	BluffButton.set_pressed(bool(game_settings.get("bluff_active", false)))
	HealthPoints.text = str(game_settings.get("health_points", 0))
	Rounds.text = str(game_settings.get("rounds", 0))
	RoundRolls.text = str(game_settings.get("round_rolls", 0))
	DiceCountRef.text = str(game_settings.get("dice_count", 0))
	DiceType.select(DiceType.get_item_index(int(game_settings.get("dice_type", 0))))
	opponent_roll_visible_button.set_pressed(bool(game_settings.get("show_rolls", false)))
	show_opponent_rolls = bool(game_settings.get("show_rolls", false))
	timed_rounds_button.set_pressed(bool(game_settings.get("timed_rounds", true)))
	timed_rounds = bool(game_settings.get("timed_rounds",true))
	round_time.text = str(game_settings.get("round_time", 25))

	# Update any hand settings-related fields if necessary
	# (for example, list of hand rules or settings if part of the UI)
	Debugger.log(str("UI fields updated with preset:", game_settings, hand_settings))

func _create_label(_text: String) -> Label:
	var label = Label.new()
	label.text = _text
	return label

# Generate single-number hands (like Ones, Twos, ... up to dice_type)
func _generate_singles():
	for i in range(1, dice_type + 1):
		var hand_name = "Hand: %d's" % i
		var hand_type = ["Singles",i]
		var hand_option = _create_hand_option(hand_name, hand_type)
		advanced_settings_vbox.add_child(hand_option)

#Bonus
func _generate_bonus():
	var hand_name = "Bonus"
	var hand_type = ["Bonus",0]
	var hand_option = _create_hand_option(hand_name, hand_type)
	advanced_settings_vbox.add_child(hand_option)

#Chance
func _generate_chance():
	var hand_name = "Chance"
	var hand_type = ["Chance",0]
	var hand_option = _create_hand_option(hand_name, hand_type)
	advanced_settings_vbox.add_child(hand_option)

# Generate straights based on dice count
func _generate_straights():
	var maxStraight = dice_count if dice_count<dice_type else dice_type
	for length in range(4, maxStraight + 1): #change 4 to allow for smaller straights
		var hand_name = "Straight of %d" % length
		var hand_type = ["Straight",length]
		var hand_option = _create_hand_option(hand_name, hand_type)
		advanced_settings_vbox.add_child(hand_option)
	#add code to state that can't do since low dice count

# Generate "Kinds" hands based on dice count
func _generate_kinds():
	# Start with "Three of a Kind" and go up to the maximum count (dice_count)
	for kind in range(3, dice_count + 1):
		if kind == dice_count: # create yahtzee hand
			var hand_name = "Dice Storm"
			var hand_type = ["Yahtzee",kind]
			var hand_option = _create_hand_option(hand_name, hand_type)
			advanced_settings_vbox.add_child(hand_option)
			break

		var hand_name = "%d of a Kind" % kind
		var hand_type = ["Kind",kind]
		var hand_option = _create_hand_option(hand_name, hand_type)
		advanced_settings_vbox.add_child(hand_option)

# Generate full houses based on dice count
func _generate_full_houses():
	# This will create (min_set_size, remaining) combinations
	for n in range(4, dice_count + 1):
		for m in range(2, floor(n / 2) + 1):
			var hand_name = "Full House (%d, %d)" % [m, n-m]
			var hand_type = ["FullHouse",m,n-m]
			var hand_option = _create_hand_option(hand_name, hand_type)
			advanced_settings_vbox.add_child(hand_option)

# Helper function to create a UI option for each hand
func _create_hand_option(hand_name: String, hand_type: Array) -> HBoxContainer:
	var hand_hbox = load("res://NodeScene/advanced_settings_hand_template.tscn").instantiate()

	# Label for the hand name
	var name_label = hand_hbox.get_node("HandName")
	name_label.text = hand_name

	# Toggle for allowing the hand
	var allowed_checkbox = hand_hbox.get_node("Allowed")
	allowed_checkbox.set_toggle_mode(true)
	allowed_checkbox.set_pressed(true)

	# Toggle for repeatable
	var repeatable_checkbox = hand_hbox.get_node("Repeatable")

	# SpinBox for maximum plays allowed
	var max_plays = hand_hbox.get_node("MaxPlays")
	if hand_name == "Dice Storm":
		max_plays.max_value = YAHTZEE_MAX_PLAYS

	# TextField for custom scoring rule
	var scoring_input = hand_hbox.get_node("ScoringRule")

	# Save settings for this hand in hand_settings dictionary
	hand_settings_refs[hand_name] = {
		"hand_type": hand_type,
		"allowed": allowed_checkbox,
		"repeatable": repeatable_checkbox,
		"max_plays": max_plays,
		"scoring_rule": scoring_input
	}

	return hand_hbox

# Saves the hand settings and hides the advanced settings UI
func save_advanced_settings():
	hand_settings_vals.clear()
	# Loop through each hand in hand_settings and save current values
	for hand_name in hand_settings_refs.keys():
		var settings = hand_settings_refs[hand_name]
		hand_settings_vals[hand_name] = {
			"hand_type": settings["hand_type"],
			"allowed": settings["allowed"].is_pressed(),#is_checked()
			"repeatable": settings["repeatable"].is_pressed(),
			"max_plays": int(settings["max_plays"].value),
			"scoring_rule": settings["scoring_rule"].text
		}
	calculateMaxHands()
	hand_settings_saved = true
	_hand_settings_vals_changed()
	_on_return_to_settings_pressed()

func _on_return_to_settings_pressed() -> void:
	# Clear current advanced settings nodes
	#for child in advanced_settings_vbox.get_children():
	#	child.queue_free()
	settingsSetup.visible = true
	presetsPanel.visible = true
	settingsAdvanced.visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	start_game_button.connect("pressed",self._on_start_game_pressed)
	start_game_button.visible = false
	copy_connect_code_button.connect("pressed",self._copy_hash_to_clipboard)
	copy_connect_code_button.visible = true
	advanced_settings_button.connect("pressed",self._on_advanced_settings_pressed)
	save_advanced_settings_button.connect("pressed",self.save_advanced_settings)
	return_to_settings_button.connect("pressed",self._on_return_to_settings_pressed)
	home_button.connect("pressed",self.on_home_pressed)
	wait_home_button.connect("pressed",self.on_home_pressed)
	WinCondition.set_toggle_mode(true)
	WinCondition.connect("item_selected", self._win_condition_toggled)
	HealthPointsBox.visible = false
	win_cond = "Score"
	opponent_roll_visible_button.set_toggle_mode(true)
	opponent_roll_visible_button.connect("toggled", self._on_roll_visible_toggled)
	show_opponent_rolls = false
	DiceType.set_toggle_mode(true)
	timed_rounds_button.set_toggle_mode(true)
	timed_rounds_button.connect("toggled", self._on_timed_round_toggled)
	BluffButton.set_toggle_mode(true)
	BluffButton.connect("toggled", self._on_bluff_toggled)
	timed_rounds = true
	DiceType.connect("item_selected", self._dice_values_changed)
	DiceCountRange.connect("value_changed", self._dice_values_changed)
	save_preset_button.connect("pressed",self.save_preset)
	NetworkManager.connect("second_player_connected", self._allow_game_start)
	player1Name.connect("text_changed", self._on_player_name_modified)
	
	# load player name
	if GlobalSettings.profile_settings["player_name"] != "":
		player1Name.text = GlobalSettings.profile_settings["player_name"]

func _on_player_name_modified(new_name) -> void:
	GlobalSettings.profile_settings["player_name"] = new_name

func _hand_settings_vals_changed() -> void:
	var total_playable_hands_counter = 0
	for hsetting in hand_settings_vals:
		if hand_settings_vals[hsetting]["allowed"]:
			if hand_settings_vals[hsetting]["repeatable"]:
				total_playable_hands_counter += hand_settings_vals[hsetting]["max_plays"]
			else:
				total_playable_hands_counter += 1
	self.total_playable_hands = total_playable_hands_counter
	RoundsSpinBox.max_value = total_playable_hands_counter

func _on_roll_visible_toggled(_state) -> void:
	if show_opponent_rolls:
		show_opponent_rolls = false
	else:
		show_opponent_rolls = true
	Debugger.log(str("Is ", show_opponent_rolls))

func _on_timed_round_toggled(_state) -> void:
	if timed_rounds:
		timed_rounds = false
		round_time_box.visible = false
	else:
		timed_rounds = true
		round_time_box.visible = true
	Debugger.log(str("Timer Is ", timed_rounds))

func _on_bluff_toggled(_state) -> void:
	bluff_active = _state
	Debugger.log(str("Bluff Is ", bluff_active))

func _dice_values_changed(_state) -> void:
	if hand_settings_saved:
		Debugger.log("Hand Settings lost")
		hand_settings_saved = false
	#code to indicate

func collectInfo() -> void:
	self.visible = true
	if NetworkManager.getIsHost():
		settingsSetup.visible = true
		settingsAdvanced.visible = false
		settingsWait.visible = false
		presetsPanel.visible = true
		copy_connect_code_button.text = "Code: " + NetworkManager.getHashIP()+NetworkManager.getHashPort()
		load_preset_buttons()
	else:
		settingsSetup.visible = false
		settingsAdvanced.visible = false
		settingsWait.visible = true
		presetsPanel.visible = false

func _copy_hash_to_clipboard():
	DisplayServer.clipboard_set(NetworkManager.getHashIP()+NetworkManager.getHashPort())
	Debugger.log(str("Connect code copied to clipboard: ", DisplayServer.clipboard_get()))

func _allow_game_start(_client_name: String) -> void:
	copy_connect_code_button.visible = false
	start_game_button.visible = true
	player2Name.text = _client_name

func on_home_pressed() -> void:
	#Add disconnect code here and network manager
	NetworkManager._on_server_disconnected()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
