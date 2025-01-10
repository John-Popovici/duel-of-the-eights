extends Node3D
# GameScene.gd

var player1_name: String
var player2_name: String

@onready var MultiGameManager: Node = $MultiGameManager
@onready var network_manager: Node = $NetworkManager


func start_game() -> void:
	print("Start Game")
	MultiGameManager.loadGameSetup()
	

func returnToIntro() -> void:
	var intro_scene = load("res://Scenes/IntroScene.tscn").instantiate()
	
	# Change scene to GameScene
	get_tree().root.add_child(intro_scene)
	queue_free()  # Free IntroScene

# Start game logic with player names
func _ready() -> void:
	network_manager.get_node("ConnectionUI").visible = true
	network_manager.connect("startGame", self.start_game)
	network_manager.connect("disconnected", self.returnToIntro)
	network_manager.connect("connection_failed", self.returnToIntro)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
