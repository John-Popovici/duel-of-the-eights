extends CanvasLayer

@export var network_manager_path: NodePath = "../../NetworkManger"
@export var default_port: int = 12345
var host_option: bool = false

# Cached references
var network_manager: Node
@onready var ip_field = $UIBox/Connection_Setup/IP_Input
@onready var port_field = $UIBox/Connection_Setup/Port_Input
@onready var host_checkbutton = $UIBox/Connection_Setup/HostCheckButton
@onready var connect_button = $UIBox/Connection_Setup/ConnectButton
@onready var back_to_home_button = $UIBox/Connection_Setup/BackToHomeButton
@onready var SetupUI = $UIBox/Connection_Setup
@onready var WaitUI = $UIBox/Connection_Wait
@onready var ErrorUI = $UIBox/Connection_Error
@onready var ErrorSourceLabel = $"UIBox/Connection_Error/Error Source"
@onready var IPDisplayLabel = $UIBox/Connection_Wait/IPDisplay
@onready var CopyIPButton = $UIBox/Connection_Wait/CopyIPButton
@onready var PortDisplayLabel = $UIBox/Connection_Wait/PortDisplay
@onready var CopyPortButton = $UIBox/Connection_Wait/CopyPortButton


func _ready():
	self.visible = true
	host_checkbutton.set_toggle_mode(true)
	host_checkbutton.connect("toggled", self._on_hostcheck_toggled)
	WaitUI.visible = false
	ErrorUI.visible = false
	# Connect the copy buttons to functions to copy IP and port
	CopyIPButton.connect("pressed", self._copy_ip_to_clipboard)
	CopyPortButton.connect("pressed", self._copy_port_to_clipboard)

func _on_hostcheck_toggled(state):
	print("Host/Client Toggled: ",state)
	host_option = state
	if host_option:
		ip_field.visible = false
		connect_button.text = "Start Hosting"
		port_field.placeholder_text = "Port (Optional - 5 digits to 65535)"
	else:
		ip_field.visible = true
		connect_button.text = "Connect"
		port_field.placeholder_text = "Port - 5 digits"

func setupNetworkManagerRef() -> void:
	network_manager = get_parent()
	network_manager.connect("connection_successful", self._on_connection_successful)
	network_manager.connect("disconnected", self._on_disconnected)
	network_manager.connect("connection_failed", self._on_connection_failed)
	connect_button.connect("pressed", self._on_connect_pressed)
	back_to_home_button.connect("pressed",self._on_disconnected)

func _on_connect_pressed():
	var port = port_field.text.to_int() if port_field.text else default_port
	
	if host_option:
		network_manager.start_server(port)
		SetupUI.visible = false
		WaitUI.visible = true
		IPDisplayLabel.text = "Connect Code: " + network_manager.getHashIP()
		PortDisplayLabel.text = "Started as Host on port: " + str(port)
	else:
		var _hash = ip_field.text
		network_manager.connect_to_server(_hash, port)

func _copy_ip_to_clipboard():
	DisplayServer.clipboard_set(network_manager.getHashIP())
	print("Connect code copied to clipboard: ", DisplayServer.clipboard_get())

func _copy_port_to_clipboard():
	var port = port_field.text.to_int() if port_field.text else default_port
	DisplayServer.clipboard_set(str(port))
	print("Port copied to clipboard: ", DisplayServer.clipboard_get())

func _on_connection_successful():
	# Hide the ConnectionUI once connected
	self.visible = false
	print("Multiplayer Successfully connected")
	# Start the game via OnlineGameManager
	get_tree().get_root().get_node("OnlineGameScene").start_game()

func _on_disconnected():
	# Hide the ConnectionUI once connected
	self.visible = true
	SetupUI.visible = false
	WaitUI.visible = false
	ErrorUI.visible = true
	ErrorSourceLabel.text = "Disconnected from game"
	print("Disconnected")
	await get_tree().create_timer(2.0).timeout
	# Start the game via OnlineGameManager
	get_tree().get_root().get_node("OnlineGameScene").returnToIntro()

func _on_connection_failed():
	# Hide the ConnectionUI once connected
	self.visible = true
	SetupUI.visible = false
	WaitUI.visible = false
	ErrorUI.visible = true
	ErrorSourceLabel.text = "Connection Failed"
	print("Connection Failed")
	await get_tree().create_timer(2.0).timeout
	# Start the game via OnlineGameManager
	get_tree().get_root().get_node("OnlineGameScene").returnToIntro()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
