extends CanvasLayer

signal game_settings_ready(game_settings)
@onready var start_game_button = $UIBox/Settings_Setup/StartGame
@onready var home_button = $UIBox/Settings_Setup/BackToHomeButton

@onready var player1Name = $UIBox/Settings_Setup/PlayerNames/Player1Name
@onready var player2Name = $UIBox/Settings_Setup/PlayerNames/Player2Name
@onready var HealthPoints = $UIBox/Settings_Setup/HealthPoints/HealthPoints
@onready var Rounds = $UIBox/Settings_Setup/Rounds/Rounds
@onready var DiceCount = $UIBox/Settings_Setup/Dice/DiceCount
@onready var DiceType = $UIBox/Settings_Setup/Dice/DiceType
@onready var HandLimit = $UIBox/Settings_Setup/HandLimit/HandLimit

@onready var NetworkManager = get_node("../../NetworkManager")

func _on_start_game_pressed():
	var game_settings = {
		"player_names": [player1Name.text, player2Name.text],
		"health_points": int(HealthPoints.text),
		"rounds": int(Rounds.text),
		"dice_count": int(DiceCount.text),
		"dice_type": DiceType.get_selected_id(),  # e.g., 6-sided or 8-sided
		"hand_limit": int(HandLimit.text)  # 0 to 99, or some predefined "unlimited" value
	}
	emit_signal("game_settings_ready", game_settings)
	self.visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	start_game_button.connect("pressed",self._on_start_game_pressed)
	home_button.connect("pressed",self.on_home_pressed)
	pass # Replace with function body.

func collectInfo() -> void:
	self.visible = true
	if NetworkManager.getIsHost():
		get_node("UIBox/Settings_Setup").visible = true
		get_node("UIBox/Settings_Wait").visible = false
	else:
		get_node("UIBox/Settings_Setup").visible = false
		get_node("UIBox/Settings_Wait").visible = true

func on_home_pressed() -> void:
	#Add disconnect code here and network manager
	get_tree().get_root().get_node("OnlineGameScene").returnToIntro()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
