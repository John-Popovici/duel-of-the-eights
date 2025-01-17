extends Node3D
# GameScene.gd

var player1_name: String
var player2_name: String

@onready var GameManager: Node = $GameManager
@onready var network_manager: Node = $NetworkManager
@onready var GameSettings: Node = $GameSettings


func load_game_settings() -> void:
	print("Start Game")
	#GameManager.loadGameSetup()
	GameSettings.collectInfo()
	

func _on_settings_ready(game_settings,hand_settings) -> void:
	GameManager._on_settings_ready(game_settings,hand_settings)
	GameSettings.visible = false
	if network_manager.getIsHost():
		print("Reached host send")
		network_manager.send_game_settings(game_settings,hand_settings)

func finish_game(winner, myPlayerFinalStats, OpponentFinalStats) -> void:
	pass

func returnToIntro() -> void:
	var intro_scene = load("res://Scenes/IntroScene.tscn").instantiate()
	
	# Change scene to GameScene
	get_tree().root.add_child(intro_scene)
	queue_free()  # Free IntroScene

# Start game logic with player names
func _ready() -> void:
	network_manager.connect("startGame", self.load_game_settings)
	network_manager.connect("disconnected", self.returnToIntro)
	network_manager.connect("connection_failed", self.returnToIntro)
	GameSettings.connect("game_settings_ready", self._on_settings_ready)
	network_manager.connect("received_game_settings", self._on_settings_ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
