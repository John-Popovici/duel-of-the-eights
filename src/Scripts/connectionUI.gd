extends CanvasLayer

# Cached references
var network_manager: Node
@onready var code_field = $UIBox/Connection_Setup/ConnectionHSplit/JoinVSplitContainer/RoomCodeInput
@onready var join_button = $UIBox/Connection_Setup/ConnectionHSplit/JoinVSplitContainer/JoinButton
@onready var host_button = $UIBox/Connection_Setup/ConnectionHSplit/CreateVSplitContainer/HostButton
@onready var back_to_home_button = $UIBox/Connection_Setup/BackToHomeButton
@onready var SetupUI = $UIBox/Connection_Setup
@onready var ErrorUI = $UIBox/Connection_Error
@onready var ErrorBack = $EscBackOverlay
@onready var ErrorSourceLabel = $"UIBox/Connection_Error/Error Source"

func _ready():
	self.visible = true
	ErrorUI.visible = false
	ErrorBack.visible = false
	SetupUI.visible = true
	join_button.disabled = true
	host_button.disabled = true


func setupNetworkManagerRef() -> void:
	network_manager = get_parent()
	network_manager.connect("connection_successful", self._on_connection_successful)
	network_manager.connect("disconnected", self._on_disconnected)
	network_manager.connect("connection_failed", self._on_connection_failed)
	host_button.connect("pressed", self._on_host_pressed)
	join_button.connect("pressed", self._on_join_pressed)
	back_to_home_button.connect("pressed",self._on_home)
	network_manager.connect_to_server()

func _on_join_pressed():
	var roomcode
	if code_field.text == "" or code_field.text == null:
		return
	else:
		roomcode = code_field.text
	network_manager.connect_as_client(roomcode)

func _on_host_pressed():
	network_manager.connect_as_host()



func _on_connection_successful():
	join_button.disabled = false
	host_button.disabled = false
	Debugger.log("Multiplayer Successfully connected")
	network_manager.disconnect("connection_successful", self._on_connection_successful)

func _on_disconnected():
	self.visible = true
	SetupUI.visible = false
	ErrorUI.visible = true
	ErrorBack.visible = true
	ErrorSourceLabel.text = "Disconnected from game"
	Debugger.log("Disconnected")
	#network_manager.disconnect_from_server()
	await get_tree().create_timer(2.0).timeout

func _on_home():
	self.visible = false
	Debugger.log("Disconnected")
	SceneSwitcher.returnToIntro()

func _on_connection_failed():
	# Hide the ConnectionUI once connected
	self.visible = true
	SetupUI.visible = false
	ErrorUI.visible = true
	ErrorBack.visible = true
	ErrorSourceLabel.text = "Connection Failed"
	Debugger.log_error("Connection Failed")
	await get_tree().create_timer(2.0).timeout
