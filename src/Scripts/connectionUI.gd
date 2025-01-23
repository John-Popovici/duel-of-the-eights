extends CanvasLayer

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
@onready var ErrorUI = $UIBox/Connection_Error
@onready var ErrorBack = $EscBackOverlay
@onready var ErrorSourceLabel = $"UIBox/Connection_Error/Error Source"

func _ready():
	self.visible = true
	host_checkbutton.set_toggle_mode(true)
	host_checkbutton.connect("toggled", self._on_hostcheck_toggled)
	ErrorUI.visible = false
	ErrorBack.visible = false
	port_field.visible = false

func _on_hostcheck_toggled(state):
	print("Host/Client Toggled: ",state)
	host_option = state
	if host_option:
		ip_field.visible = false
		connect_button.text = "Start Hosting"
		port_field.visible = true
		port_field.placeholder_text = "Port (Optional - 5 digits to 65535)"
	else:
		ip_field.visible = true
		connect_button.text = "Connect"
		port_field.visible = false
		port_field.placeholder_text = "Port - 5 digits"

func setupNetworkManagerRef() -> void:
	network_manager = get_parent()
	network_manager.connect("connection_successful", self._on_connection_successful)
	network_manager.connect("disconnected", self._on_disconnected)
	network_manager.connect("connection_failed", self._on_connection_failed)
	connect_button.connect("pressed", self._on_connect_pressed)
	back_to_home_button.connect("pressed",self._on_home)

func _cancel_hosting() -> void:
	self.visible = false
	SetupUI.visible = false
	ErrorUI.visible = true
	ErrorBack.visible = true
	ErrorSourceLabel.text = "Disconnected from game"
	print("Disconnected")
	network_manager.disconnect_from_server()
	await get_tree().create_timer(2.0).timeout

func _on_connect_pressed():
	var port = port_field.text.to_int() if port_field.text else default_port
	# with server hosting, most likely, the port will be chosen internally and dynamically
	
	if host_option:
		network_manager.start_server(port)
		SetupUI.visible = false
		print(network_manager.getHashIP())
		print(network_manager.getHashPort())
		_on_connection_successful()
	else:
		var _hash = ip_field.text
		network_manager.connect_to_server(_hash)


func _on_connection_successful():
	# Hide the ConnectionUI once connected
	self.visible = false
	print("Multiplayer Successfully connected")
	network_manager.disconnect("connection_successful", self._on_connection_successful)
	network_manager.connect("connection_successful", network_manager._second_player_connected)
	# Start the game via OnlineGameManager
	network_manager.emit_signal("startGame")

func _on_disconnected():
	self.visible = true
	SetupUI.visible = false
	ErrorUI.visible = true
	ErrorBack.visible = true
	ErrorSourceLabel.text = "Disconnected from game"
	print("Disconnected")
	#network_manager.disconnect_from_server()
	await get_tree().create_timer(2.0).timeout

func _on_home():
	self.visible = false
	print("Disconnected")
	get_parent().get_parent().returnToIntro()

func _on_connection_failed():
	# Hide the ConnectionUI once connected
	self.visible = true
	SetupUI.visible = false
	ErrorUI.visible = true
	ErrorBack.visible = true
	ErrorSourceLabel.text = "Connection Failed"
	print("Connection Failed")
	await get_tree().create_timer(2.0).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
