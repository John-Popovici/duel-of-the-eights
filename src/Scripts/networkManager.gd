extends Node

@export var default_port: int = 12345
var is_host: bool = false
var ConnectionUI: CanvasLayer
var OnlineGameManager: Node3D

signal connection_successful
signal disconnected
signal connection_failed

var ping_timeout: float = 3.0
var time_since_last_ping: float = 0.0
var check_ping: bool = false

# Start as a server
func start_server(port: int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 2)  # Set maximum peers to 2 (host + 1 client)
	multiplayer.multiplayer_peer = peer
	is_host = true
	print("Started as server on port: ", port)
	print("IP: ", IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1))
	multiplayer.multiplayer_peer.connect("peer_connected", self._on_peer_connected)
	#setup tracking for peer disconnect
	multiplayer.multiplayer_peer.connect("peer_disconnected", self._on_peer_disconnected)

# Connect as a client
func connect_to_server(hash: String, port: int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(hash_to_ip(hash), port)
	multiplayer.multiplayer_peer = peer
	is_host = false
	print("Attempting to connect to server at ", hash_to_ip(hash), " on port ", port)
	
	# Check if connection is successful
	multiplayer.multiplayer_peer.connect("peer_connected", self._on_peer_connected)
	#Connection Failed case
	multiplayer.multiplayer_peer.connect("connection_failed", self._on_connection_failed)
	

func _on_peer_connected(id: int):
	print("Connected to peer with ID: ", id)
	check_ping = true
	emit_signal("connection_successful")

func _on_peer_disconnected(id: int):
	print("Disconnected from peer with ID: ", id)
	emit_signal("disconnected")

func _on_server_disconnected():
	print("Disconnected from server")
	emit_signal("disconnected")

func _on_connection_failed():
	print("Connection Failed")
	emit_signal("connection_failed")

# Converts a number to a two-character uppercase string, handling 0-255
func number_to_letters(value: int) -> String:
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	# Numbers 0-99
	if value >= 0 and value <= 9:
		return "A" + alphabet[value]  # Single digit: Pad with 'A'
	elif value >= 10 and value <= 99:
		var first_letter = alphabet[(value / 10)]
		var second_letter = alphabet[value % 10]
		return first_letter + second_letter
	
	# Numbers 100-255: Map starting from "AA" for 100, "AB" for 101, up to "IZ" for 255
	elif value >= 100 and value <= 255:
		var first_letter = alphabet[((value - 100) / 26)]
		var second_letter = alphabet[(value - 100) % 26]
		return "I" + first_letter + second_letter
	
	return ""  # Return empty for out-of-range values

# Converts a 2-character uppercase code back to a number
func letters_to_number(code: String) -> int:
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	# Decode single digit (0-9)
	if code[0] == "A":
		return alphabet.find(code[1])
	
	# Decode two-digit numbers (10-99)
	var tens = alphabet.find(code[0])
	var units = alphabet.find(code[1])
	if tens != -1 and units != -1:
		return tens * 10 + units
	
	# Decode numbers 100-255
	if code[0] == "I":
		var hundreds = alphabet.find(code[1])
		var remainder = alphabet.find(code[2])
		return 100 + hundreds * 26 + remainder
	
	return -1  # Invalid code


func ip_to_hash(ip: String) -> String:
	# Converts an IP address (e.g., "192.168.0.1") to a 10-character uppercase string
	var octets = ip.split(".")
	if octets.size() != 4:
		return ""  # Invalid IP format
	
	var code = ""
	for octet in octets:
		code += number_to_letters(int(octet))  # Convert each octet to 2-character code

	return code

func hash_to_ip(hash_code: String) -> String:
	# Converts a 10-character code back to an IP address (e.g., "C0A80001")
	if hash_code.length() != 10:
		return ""  # Invalid code length

	var ip = []
	for i in range(0, 10, 2):
		var octet_code = hash_code.substr(i, 2)
		ip.append(str(letters_to_number(octet_code)))  # Convert each 2-character code back to octet

	return ip.join(".")

func getIsHost() -> bool:
	return is_host

func getHashIP() -> String:
	return ip_to_hash(str(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ConnectionUI = get_node("ConnectionUI")
	ConnectionUI.setupNetworkManagerRef()

# Reset the timer on each ping received
@rpc
func ping() -> void:
	time_since_last_ping = 0.0

func _process(delta: float) -> void:
	if is_host:
		# Broadcast a ping every second (adjust interval as necessary)
		if Time.get_ticks_msec() % 1000 < delta * 1000:
			rpc("ping")
	elif !is_host and check_ping:
		# Update the timer
		time_since_last_ping += delta
		
		# Check if the timeout is exceeded
		if time_since_last_ping >= ping_timeout:
			_on_server_disconnected()
			check_ping = false
	pass
