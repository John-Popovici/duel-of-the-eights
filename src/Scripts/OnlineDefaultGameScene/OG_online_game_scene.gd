extends Node3D
# GameScene.gd

var player1_name: String
var player2_name: String

@onready var GameManager: Node = $GameManager
@onready var network_manager: Node = $NetworkManager
@onready var GameSettings: Node = $GameSettings


func load_game_settings() -> void:
	network_manager.disconnect("startGame", self.load_game_settings)
	Debugger.log("Start Game")
	GameSettings.collectInfo()
	

func _on_settings_ready(game_settings,hand_settings) -> void:
	GameManager._on_settings_ready(game_settings,hand_settings)
	GameSettings.visible = false
	if network_manager.getIsHost():
		Debugger.log("Reached host send")
		network_manager.send_game_settings(game_settings,hand_settings)

func finish_game(winner, myPlayerFinalStats, OpponentFinalStats) -> void:
	pass

func returnToIntro() -> void:
	SceneSwitcher.returnToIntro()

# Start game logic with player names
func _ready() -> void:
	network_manager.connect("startGame", self.load_game_settings)
	network_manager.connect("disconnected", self.returnToIntro)
	network_manager.connect("connection_failed", self.returnToIntro)
	GameSettings.connect("game_settings_ready", self._on_settings_ready)
	network_manager.connect("received_game_settings", self._on_settings_ready)
	AudioManager.connect_buttons()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
