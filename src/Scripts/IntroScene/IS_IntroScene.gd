extends Node3D

# IntroScene.gd

@onready var player1_name_input = $VBoxContainer/Player1Entry  # Reference to Player 1's LineEdit
@onready var player2_name_input = $VBoxContainer/Player2Entry  # Reference to Player 2's LineEdit
@onready var start_local_button = $VBoxContainer/StartLocalGame # Reference to the Start Button
@onready var start_online_button = $VBoxContainer/StartOnlineGame # Reference to the Start Button
@onready var start_online_long_form_button = $VBoxContainer/StartOnlineLongFormGame # Reference to the Start Button
@onready var customization_button = $OptionsPanel/VBoxContainer/Customization
@onready var settings_button = $OptionsPanel/VBoxContainer/Settings

# Called when the node enters the scene tree
func _ready() -> void:
	start_local_button.pressed.connect(_on_start_local_game_pressed)
	start_online_button.pressed.connect(_on_start_online_game_pressed)
	start_online_long_form_button.pressed.connect(_on_start_online_long_form_game_pressed)
	customization_button.pressed.connect(_on_customization_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

# Transition to GameScene with player names
func _on_start_local_game_pressed() -> void:
	var player1_name = player1_name_input.text
	var player2_name = player2_name_input.text
	
	# Load GameScene
	var local_game_scene = load("res://Scenes/local_game_scene.tscn").instantiate()
	
	# Pass player names to GameScene
	local_game_scene.set_player_names(player1_name, player2_name)
	
	# Change scene to GameScene
	get_tree().root.add_child(local_game_scene)
	queue_free()  # Free IntroScene

func _on_start_online_game_pressed() -> void:
	# Load GameScene
	var online_game_scene = load("res://Scenes/online_game_scene.tscn").instantiate()
	
	# Change scene to GameScene
	get_tree().root.add_child(online_game_scene)
	queue_free()  # Free IntroScene

func _on_start_online_long_form_game_pressed() -> void:
	# Load GameScene
	var online_game_scene = load("res://Scenes/online_long_form_pvp_scene.tscn").instantiate()
	
	# Change scene to GameScene
	get_tree().root.add_child(online_game_scene)
	queue_free()  # Free IntroScene

# Transition to GameScene with player names
func _on_customization_pressed() -> void:
	# Load GameScene
	var customization = load("res://Scenes/global_customization_scene.tscn").instantiate()
	
	# Change scene to GameScene
	get_tree().root.add_child(customization)
	queue_free()  # Free IntroScene

func _on_settings_pressed() -> void:
	# Load GameScene
	var settings = load("res://Scenes/player_settings_scene.tscn").instantiate()
	
	# Change scene to GameScene
	get_tree().root.add_child(settings)
	queue_free()  # Free IntroScene 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
