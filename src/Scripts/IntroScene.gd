extends Node3D

# IntroScene.gd

@onready var player1_name_input = $VBoxContainer/Player1Entry  # Reference to Player 1's LineEdit
@onready var player2_name_input = $VBoxContainer/Player2Entry  # Reference to Player 2's LineEdit
@onready var start_button = $VBoxContainer/StartGame           # Reference to the Start Button

# Called when the node enters the scene tree
func _ready() -> void:
	start_button.pressed.connect(_on_start_game_pressed)

# Transition to GameScene with player names
func _on_start_game_pressed() -> void:
	var player1_name = player1_name_input.text
	var player2_name = player2_name_input.text
	
	# Load GameScene
	var game_scene = load("res://Scenes/game_scene.tscn").instantiate()
	
	# Pass player names to GameScene
	game_scene.set_player_names(player1_name, player2_name)
	
	# Change scene to GameScene
	get_tree().root.add_child(game_scene)
	queue_free()  # Free IntroScene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
