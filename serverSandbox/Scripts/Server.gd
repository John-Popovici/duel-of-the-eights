extends Node

@export var default_port: int = 12345
var port
var is_host: bool = false
var ConnectionUI: CanvasLayer

signal connection_successful
signal disconnected
signal connection_failed

var ping_timeout: float = 10.0
var time_since_last_ping: float = 0.0
var check_ping: bool = false

@onready var lobby = get_node("Lobby")
@onready var room = get_node("Lobby/Room")

func start_server(_port: int = default_port):
	var peer = ENetMultiplayerPeer.new()
	port = _port
	var error = peer.create_server(port, 3)  # Set maximum peers to 2 (host + 1 client)
	if error != OK:
		print(str("Cannot Host: ", error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	is_host = true
	print(str("Started as server on port: ", port))
	print(str("IP: ", IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)))
	multiplayer.multiplayer_peer.connect("peer_connected", self._on_peer_connected)
	#setup tracking for peer disconnect
	multiplayer.multiplayer_peer.connect("peer_disconnected", self._on_peer_disconnected)

func _on_peer_connected(id: int):
	print(str("Connected to peer with ID: ", id))
	print(str("Connected peers: ", multiplayer.has_multiplayer_peer()))
	#check_ping = true
	room.add_peer(id)
	#emit_signal("connection_successful")

func _on_peer_disconnected(id: int):
	print(str("Disconnected from peer with ID: ", id))
	room.remove_peer(id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	room.initialize_room(1,"Custom")
	start_server()
	pass # Replace with function body.


####################  RPCs ###########################

# Reset the timer on each ping received
@rpc("any_peer")
func ping() -> void:
	time_since_last_ping = 0.0

# Broadcasts disconnect
func broadcast_disconnect(state: String = "", data: Dictionary = {}):
	print("Broadcasting Disconnect")
	rpc("receive_disconnect")
	remove_from_group("NetworkHandlingNodes")

# Remote function to handle incoming game state updates
@rpc("any_peer")
func receive_disconnect():
	print("Recieved Disconnect")
	#emit_signal("disconnected")
	#_try_reconnect()
	#SceneSwitcher.returnToIntro()
	#remove_from_group("NetworkHandlingNodes")

# Broadcasts the game state to keep both players in sync
func broadcast_game_state(state: String, data: Dictionary):
	print(str("Broadcasting state: ", state, "with data: ", data, "from Server"))
	rpc("receive_game_state", state, data)

# Remote function to handle incoming game state updates
@rpc("any_peer")
func receive_game_state(state: String, data: Dictionary):
	print(str("Received state: ", state, " with data: ", data, " on Server"))

@rpc("any_peer","call_remote")
func receive_game_settings(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	var game_settings = _game_settings
	var hand_settings = _hand_settings
	print("Server recieved settings")

func send_game_settings(_game_settings: Dictionary,_hand_settings: Dictionary) -> void:
	var game_settings = _game_settings
	var hand_settings = _hand_settings
	print("Server sent settings")
	rpc("receive_game_settings",_game_settings, _hand_settings)

func send_chat_rpc(message: String):
	rpc("receive_chat_rpc", message)  # Broadcast to all clients


@rpc("any_peer","reliable","call_remote")
func receive_chat_rpc(message: String):
	print(message)
