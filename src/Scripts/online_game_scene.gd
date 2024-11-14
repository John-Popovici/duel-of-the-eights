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
	

func start_game() -> void:
	print("Start Game")
	GameManager.loadGameSetup()
	

func returnToIntro() -> void:
	var intro_scene = load("res://Scenes/IntroScene.tscn").instantiate()
	
	# Change scene to GameScene
	get_tree().root.add_child(intro_scene)
	queue_free()  # Free IntroScene

# Start game logic with player names
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
