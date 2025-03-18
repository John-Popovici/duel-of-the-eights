extends Node

@export var default_port: int = 12345
@export var default_server_ip: String = "3.147.230.87" #elastic IP address
var port
var is_host: bool = false
var ConnectionUI: CanvasLayer

signal connection_successful
signal disconnected
signal connection_failed

var ping_timeout: float = 5.0 #change back to 10.0
var time_since_last_ping: float = 0.0
var check_ping: bool = false

# Start as a server
func start_server(_port: int = default_port):
	var peer = ENetMultiplayerPeer.new()
	var ip = default_server_ip

	port = default_port
	var error = peer.create_client(ip, port)
	if error != OK:
		Debugger.log_error(str("Cannot Join as Client: ", error))
		Debugger.log_error(str("Cannot Join as Client to: ", default_server_ip, " on port ", port))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	is_host = true
	Debugger.log(str("Attempting to connect to server at ", ip, " on port ", port))
	
	multiplayer.multiplayer_peer.connect("peer_connected", self._on_peer_connected)
	#setup tracking for peer disconnect
	multiplayer.multiplayer_peer.connect("peer_disconnected", self._on_peer_disconnected)

# Connect as a client
func connect_to_server(_hash: String = "nullEmpty"):
	var peer = ENetMultiplayerPeer.new()
	var ip = default_server_ip
	port = default_port
	var error = peer.create_client(ip, port)
	if error != OK:
		Debugger.log_error(str("Cannot Join as Client: ", error))
		Debugger.log_error(str("Cannot Join as Client to: ", default_server_ip, " on port ", port))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	is_host = false
	Debugger.log(str("Attempting to connect to server at ", ip, " on port ", port))
	
	# Check if connection is successful
	multiplayer.multiplayer_peer.connect("peer_connected", self._on_peer_connected)
	#Connection Failed case
	multiplayer.multiplayer_peer.connect("connection_failed", self._on_connection_failed)

func _on_peer_connected(id: int):
	Debugger.log(str("Connected to peer with ID: ", id))
	Debugger.log(str("Connected peers: ", multiplayer.has_multiplayer_peer()))
	check_ping = true
	emit_signal("connection_successful")
##### Add stuff to _on_peer_connected or _second_player_connected to transmit name info or profile info
signal second_player_connected(Name: String)
func _second_player_connected():
	emit_signal("second_player_connected", GlobalSettings.profile_settings["player_name"])

func _on_peer_disconnected(id: int):
	Debugger.log(str("Disconnected from peer with ID: ", id))
	_try_reconnect()

func _on_server_disconnected():
	Debugger.log(str("Disconnected from server"))
	_try_reconnect()

func _on_connection_failed():
	Debugger.log(str("Connection Failed"))
	multiplayer.multiplayer_peer = null
	emit_signal("connection_failed")
	remove_from_group("NetworkHandlingNodes")

func _try_reconnect():
	emit_signal("disconnected")
	broadcast_disconnect()
	multiplayer.multiplayer_peer = null
	remove_from_group("NetworkHandlingNodes")

# Converts a base-10 integer (0-600) to a base-26 string with letters A-Z representing 0-25
func numberToLetters(number: int) -> String:
	var result = ""
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	# Ensure number is within the valid range
	#if number < 0 or number > 600:
	#	return ""
	
	while number >= 0:
		var remainder = number % 26
		result = alphabet[remainder] + result
		number = number / 26 - 1  # Shift down by 1 to handle 26 as a "zero-indexed" system
		if number < 0:
			break

	# Ensure result is always 2 characters long
	if result.length() < 2:
		return "A" + result
	return result


# Converts a base-26 string with letters A-Z back to a base-10 integer
func lettersToNumber(letters: String) -> int:
	var result = 0
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	letters = letters.lstrip("A")
	if letters == "":
		return result
	
	for i in range(letters.length()):
		var letter_value = alphabet.find(letters[i])
		result = result * 26 + (letter_value + 1)
	
	return result - 1  # Adjust final result to account for the offset

func ip_to_hash(ip: String) -> String:
	# Converts an IP address to a 10-character uppercase string
	var octets = ip.split(".")
	if octets.size() != 4:
		return ""  # Invalid IP format
	
	var code = ""
	for octet in octets:
		code += numberToLetters(int(octet))  # Convert each octet to 2-character code

	return code

func hash_to_ip(hash_code: String) -> String:
	# Converts a 10-character code back to an IP address
	Debugger.log(str("Hash code to convert: ", hash_code))
	if hash_code.length() != 8:
		Debugger.log_error("invalid length")
		return ""  # Invalid code length

	var ip = []
	for i in range(0, hash_code.length(), 2):
		var octet_code = hash_code.substr(i, 2)
		ip.append(str(lettersToNumber(octet_code)))  # Convert each 2-character code back to octet
	Debugger.log(str("ip before join: ", ip))
	return ".".join(ip)


func getIsHost() -> bool:
	return is_host

func getHashIP() -> String:
	return ip_to_hash(str(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)))

func getHashPort() -> String:
	return numberToLetters(port)

func disconnect_from_server() -> void:
	emit_signal("disconnected")
	_try_reconnect()
	multiplayer.multiplayer_peer = null
	remove_from_group("NetworkHandlingNodes")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ConnectionUI = get_node("ConnectionUI")
	ConnectionUI.setupNetworkManagerRef()
	connect("disconnected", self.broadcast_disconnect)
	add_to_group("NetworkHandlingNodes")
	

signal startGame

# Broadcasts disconnect
func broadcast_disconnect(state: String = "", data: Dictionary = {}):
	Debugger.log("Broadcasting Disconnect")
	rpc("receive_disconnect")
	remove_from_group("NetworkHandlingNodes")

# Remote function to handle incoming game state updates
@rpc("any_peer")
func receive_disconnect():
	Debugger.log("Recieved Disconnect")
	emit_signal("disconnected")
	_try_reconnect()
	SceneSwitcher.returnToIntro()
	#remove_from_group("NetworkHandlingNodes")

signal game_state_received(state: String, data: Dictionary)

# Broadcasts the game state to keep both players in sync
func broadcast_game_state(state: String, data: Dictionary):
	Debugger.log(str("Broadcasting state: ", state, "with data: ", data, "from host: ", getIsHost()))
	rpc("receive_game_state", state, data)

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
	rpc("receive_game_settings",_game_settings, _hand_settings)


func send_chat_rpc(message: String):
	rpc("receive_chat_rpc", message)  # Broadcast to all clients


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
