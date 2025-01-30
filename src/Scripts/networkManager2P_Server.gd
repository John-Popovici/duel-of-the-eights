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

var server_ip: String = "54.174.171.0"  # Replace with your server's IP
var server_port: int = 9999  # Replace with your server's port

# Start as a server
func start_server(_port: int = server_port):
	var peer = ENetMultiplayerPeer.new()
	port = _port
	var error = peer.create_server(_port, 2)  # Set max peers to 2 (host + 1 client)
	if error != OK:
		print("Cannot Host: ", error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	is_host = true
	print("Started as server on port: ", _port)
	print("IP: ", server_ip)
	
	# Connect to the server as a client
	var multiplayer_peer = ENetMultiplayerPeer.new()
	var result = multiplayer_peer.create_client(server_ip, server_port)
	if result != OK:
		print("Failed to create client connection. Error code: %d" % result)
		return

	# Set the multiplayer peer
	multiplayer.multiplayer_peer = multiplayer_peer

	# Connect to the signals for connection events
	multiplayer.connect("network_peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.connect("network_peer_disconnected", Callable(self, "_on_peer_disconnected"))
	multiplayer_peer.connect("connection_error", Callable(self, "_on_connection_error"))

	print("Attempting to connect to server at ", server_ip, " on port ", server_port)

# Connect as a client
func connect_to_server(_hash: String):
	var multiplayer_peer = ENetMultiplayerPeer.new()
	var result = multiplayer_peer.create_client(server_ip, server_port)
	if result != OK:
		print("Failed to create client connection. Error code: %d" % result)
		return

	# Set the multiplayer peer
	multiplayer.multiplayer_peer = multiplayer_peer

	# Connect to the signals for connection events
	multiplayer.connect("network_peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.connect("network_peer_disconnected", Callable(self, "_on_peer_disconnected"))
	multiplayer_peer.connect("connection_error", Callable(self, "_on_connection_error"))

	print("Attempting to connect to server at ", server_ip, " on port ", server_port)


func _on_peer_connected(id: int):
	print("Connected to peer with ID: ", id)
	print("Connected peers: ", multiplayer.has_multiplayer_peer())
	check_ping = true
	emit_signal("connection_successful")
##### Add stuff to _on_peer_connected or _second_player_connected to transmit name info or profile info
signal second_player_connected(Name: String)
func _second_player_connected():
	emit_signal("second_player_connected","Client") #Change to be the players profile name

func _on_peer_disconnected(id: int):
	print("Disconnected from peer with ID: ", id)
	_try_reconnect()

func _on_server_disconnected():
	print("Disconnected from server")
	_try_reconnect()

func _on_connection_failed():
	print("Connection Failed")
	multiplayer.multiplayer_peer = null
	emit_signal("connection_failed")
	remove_from_group("NetworkHandlingNodes")

func _try_reconnect():
	emit_signal("disconnected")
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
	if hash_code.length() != 10:
		return ""  # Invalid code length

	var ip = []
	for i in range(0, hash_code.length(), 2):
		var octet_code = hash_code.substr(i, 2)
		ip.append(str(lettersToNumber(octet_code)))  # Convert each 2-character code back to octet

	return ".".join(ip)


func getIsHost() -> bool:
	return is_host

func getHashIP() -> String:
	return ip_to_hash(str(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)))

func getHashPort() -> String:
	return numberToLetters(port)

func disconnect_from_server() -> void:
	emit_signal("disconnected")
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
func broadcast_disconnect(state: String, data: Dictionary):
	rpc("receive_disconnect")
	remove_from_group("NetworkHandlingNodes")

# Remote function to handle incoming game state updates
@rpc("any_peer")
func receive_disconnect():
	emit_signal("disconnected")
	remove_from_group("NetworkHandlingNodes")

signal game_state_received(state: String, data: Dictionary)

# Broadcasts the game state to keep both players in sync
func broadcast_game_state(state: String, data: Dictionary):
	print("Broadcasting state: ", state, "with data: ", data, "from host: ", getIsHost())
	rpc("receive_game_state", state, data)

# Remote function to handle incoming game state updates
@rpc("any_peer")
func receive_game_state(state: String, data: Dictionary):
	print("Received state: ", state, " with data: ", data, " on host: ", getIsHost())
	emit_signal("game_state_received", state, data)

# Reset the timer on each ping received
@rpc
func ping() -> void:
	time_since_last_ping = 0.0

signal received_game_settings(_game_settings: Dictionary, _hand_settings: Dictionary)

@rpc
func receive_game_settings(_game_settings: Dictionary, _hand_settings: Dictionary) -> void:
	var game_settings = _game_settings
	var hand_settings = _hand_settings
	print("Network Manager recieved settings")
	emit_signal("received_game_settings",game_settings,hand_settings)

func send_game_settings(_game_settings: Dictionary,_hand_settings: Dictionary) -> void:
	var game_settings = _game_settings
	var hand_settings = _hand_settings
	print("Network Manager sent settings")
	rpc("receive_game_settings",_game_settings, _hand_settings)

func _process(delta: float) -> void:
	if is_host:
		# Broadcast a ping every second (adjust interval as necessary)
		if Time.get_ticks_msec() % 1000 < delta * 1000:
			rpc("ping")
			if !multiplayer.has_multiplayer_peer():
				emit_signal("disconnected")
				multiplayer.multiplayer_peer = null
				print("Client Disconnected")
				remove_from_group("NetworkHandlingNodes")
	elif !is_host and check_ping:
		# Update the timer
		time_since_last_ping += delta
		
		# Check if the timeout is exceeded
		if time_since_last_ping >= ping_timeout:
			print("Host Ping Timedout")
			_on_server_disconnected()
			check_ping = false
	pass
