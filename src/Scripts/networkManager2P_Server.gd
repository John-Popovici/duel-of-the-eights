extends Node

@export var default_port: int = 9999
@export var default_server_ip: String = "54.174.171.0" #elastic IP address
var port
var room_code = ""  # Stores the room code
var peer_id = "" # Stores the id of peer
var peer_info = {}
var is_host: bool = false
var ConnectionUI: CanvasLayer

signal connection_failed
signal connection_successful
signal second_player_connected

var ping_timeout: float = 5.0 #change back to 10.0
var time_since_last_ping: float = 0.0
var check_ping: bool = false

func connect_to_server():
	var peer = ENetMultiplayerPeer.new()
	var ip = default_server_ip
	#ip = "192.168.0.106"#"192.168.0.107" #For local Windows Testing (replace with own ip)
	
	port = default_port
	var error = peer.create_client(ip, port)
	if error != OK:
		Debugger.log_error(str("Cannot Connect to server: ", error))
		Debugger.log_error(str("Cannot Connect to server at: ", default_server_ip, " on port ", port))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	Debugger.log(str("Attempting to connect to server at ", ip, " on port ", port))
	
	multiplayer.multiplayer_peer.connect("peer_connected", self._on_peer_connected)
	#Connection Failed case
	multiplayer.multiplayer_peer.connect("connection_failed", self._on_connection_failed)


# Start as a server
func connect_as_host(_port: int = default_port):
	create_room()
	is_host = true

# Connect as a client
func connect_as_client(_code: String):
	join_room(_code)
	is_host = false

func _on_peer_connected(id: int):
	Debugger.log(str("Connected to peer with ID: ", id))
	Debugger.log(str("Connected peers: ", multiplayer.has_multiplayer_peer()))
	emit_signal("connection_successful")
	check_ping = true


func _on_peer_disconnected(id: int):
	Debugger.log(str("Disconnected from peer with ID: ", id))
	broadcast_disconnect()

func _on_server_disconnected():
	Debugger.log(str("Disconnected from server"))
	broadcast_disconnect()

func _on_connection_failed():
	Debugger.log(str("Connection Failed"))
	broadcast_disconnect()
	multiplayer.multiplayer_peer = null
	remove_from_group("NetworkHandlingNodes")
	SceneSwitcher.returnToIntro()

func getIsHost() -> bool:
	return is_host

func getHashIP() -> String:
	return room_code

func getHashPort() -> String:
	return ""

func disconnect_from_server() -> void:
	broadcast_disconnect()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ConnectionUI = get_node("ConnectionUI")
	add_to_group("NetworkHandlingNodes")
	ConnectionUI.setupNetworkManagerRef()


signal startGame

# Broadcasts disconnect
func broadcast_disconnect(state: String = "", data: Dictionary = {}):
	Debugger.log("Broadcasting Disconnect")
	rpc("receive_disconnect")
	multiplayer.multiplayer_peer = null
	remove_from_group("NetworkHandlingNodes")
	SceneSwitcher.returnToIntro()
	

# Remote function to handle incoming game state updates
@rpc("any_peer")
func receive_disconnect():
	Debugger.log("Recieved Disconnect")
	broadcast_disconnect()

@rpc("reliable")
func room_created(code):
	room_code = code
	print("Successfully created room with code:", room_code)
	#Close Connection UI, Open Game Settings
	emit_signal("startGame")
	ConnectionUI.visible = false

@rpc("reliable")
func room_joined(code, hostid):
	room_code = code
	peer_id = hostid
	print("Successfully joined room:", room_code, " with peer's ID: ", hostid)
	#If hosting in game settings, allow start game
	emit_signal("startGame")
	emit_signal("second_player_connected","Client")
	ConnectionUI.visible = false

@rpc("reliable")
func room_join_failed():
	print("Failed to join room. Room does not exist or is full.")

@rpc("any_peer", "reliable")
func create_room():
	if multiplayer.is_server():
		print("Already acting as a server. Cannot create room.")
		return
	rpc_id(1, "create_room")  # Ask the server to create a room

@rpc("any_peer", "reliable")
func join_room(code: String):
	if multiplayer.is_server():
		print("Already acting as a server. Cannot join a room.")
		return
	rpc_id(1, "join_room", code)  # Ask the server to join a room

################# Game Data Transmission ###################

signal game_state_received(state: String, data: Dictionary)

# Broadcasts the game state to keep both players in sync
func broadcast_game_state(state: String, data: Dictionary):
	Debugger.log(str("Broadcasting state: ", state, "with data: ", data, "from host: ", getIsHost()))
	rpc_id(1,"receive_game_state", state, data)

# Remote function to handle incoming game state updates
@rpc("any_peer")
func receive_game_state(state: String, data: Dictionary):
	Debugger.log(str("Received state: ", state, " with data: ", data, " on host: ", getIsHost()))
	emit_signal("game_state_received", state, data)

# Reset the timer on each ping received
@rpc("any_peer")
func ping() -> void:
	time_since_last_ping = 0.0

signal received_game_settings(_game_settings: Dictionary, _hand_settings: Dictionary)

@rpc("any_peer","call_remote")
func receive_game_settings(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	var game_settings = _game_settings
	var hand_settings = _hand_settings
	Debugger.log("Network Manager recieved settings")
	emit_signal("received_game_settings",game_settings,hand_settings)

func send_game_settings(_game_settings: Dictionary,_hand_settings: Dictionary) -> void:
	var game_settings = _game_settings
	var hand_settings = _hand_settings
	Debugger.log("Network Manager sent settings")
	rpc_id(1,"receive_game_settings",_game_settings, _hand_settings)


func send_chat_rpc(message: String):
	rpc_id(1,"receive_chat_rpc", message)  # Broadcast to all clients


signal chat_received(message: String)

@rpc("any_peer","reliable","call_remote")
func receive_chat_rpc(message: String):
	chat_received.emit(message)

func _process(delta: float) -> void:
	if check_ping:
		# Update the timer
		time_since_last_ping += delta
		
		# Check if the timeout is exceeded
		if time_since_last_ping >= ping_timeout:
			Debugger.log("Host Ping Timedout")
			_on_server_disconnected()
			check_ping = false
	pass
