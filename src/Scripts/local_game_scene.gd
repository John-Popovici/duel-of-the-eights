extends Node3D
# GameScene.gd

var player1_name: String
var player2_name: String

@onready var GameManager: Node = $GameManager

# Method to set player names, called from IntroScene
func set_player_names(name1: String, name2: String) -> void:
	player1_name = name1
	player2_name = name2
	print("Player 1: %s, Player 2: %s" % [player1_name, player2_name])
	

# Start game logic with player names
func _ready() -> void:
	if player1_name and player2_name:
		print("Starting game with players: %s and %s" % [player1_name, player2_name])
		GameManager.setPlayerNames(player1_name,player2_name)
		#GameManager.start_round()
	else:
		print("Warning: Player names not set")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
