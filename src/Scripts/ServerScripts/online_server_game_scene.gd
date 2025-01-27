extends Node3D

@export var server_ip: String = "54.174.171.0"  # EC2 public IP
@export var server_port: int = 9999

var multiplayer_peer: ENetMultiplayerPeer
var online_label: Label  # Path to the label for displaying the connection status
var connection_timer: Timer  # Timer for connection timeout

func _ready():
	# Connect the button's "pressed" signal to the connect function using Callable
	var button = $VBoxContainer/ServerConnectButton  # Path to the button inside VBoxContainer
	button.connect("pressed", Callable(self, "_on_button_pressed"))  # Connect signal to function
	
	# Ensure the label exists and is correctly assigned
	online_label = $VBoxContainer/ServerOnlineCheck  # Update this path if necessary
	if online_label == null:
		print("Error: Could not find the label for connection status.")
		return

	# Initially set the status to "Offline"
	online_label.text = "Offline"

	# Connect the disconnect button's "pressed" signal to the disconnect function
	var disconnect_button = $VBoxContainer/ServerDisconnectButton  # Path to the disconnect button
	disconnect_button.connect("pressed", Callable(self, "_on_disconnect_button_pressed"))  # Connect signal to function

	# Create and configure the connection timeout timer
	connection_timer = Timer.new()
	connection_timer.wait_time = 5  # 10 seconds timeout
	connection_timer.one_shot = true  # Timer will stop after one run
	connection_timer.connect("timeout", Callable(self, "_on_connection_timeout"))
	add_child(connection_timer)  # Add the timer to the scene

# Function to handle connection to the server
func _on_button_pressed():
	connect_to_server()  # Replace with actual hash if needed

# Function to create the client and connect to the server
func connect_to_server():
	multiplayer_peer = ENetMultiplayerPeer.new()
	
	# Attempt to create the client connection
	var result = multiplayer_peer.create_client(server_ip, server_port)
	if result != OK:
		print("Failed to create client connection. Error code: %d" % result)
		online_label.text = "Failed to connect to server"
		return

	# Set the multiplayer peer
	multiplayer.multiplayer_peer = multiplayer_peer

	# Connect signals for connection events
	multiplayer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))

	print("Attempting to connect to server at ", server_ip, " on port ", server_port)
	online_label.text = "Connecting to server..."
	connection_timer.start()  # Start the timer for the connection attempt

# Signal handler when a peer is connected
func _on_peer_connected(id: int):
	print("Peer connected with ID: ", id)
	online_label.text = "Connected to server"
	connection_timer.stop()  # Stop the timeout timer

# Signal handler when a peer is disconnected
func _on_peer_disconnected(id: int):
	print("Peer disconnected with ID: ", id)
	online_label.text = "Disconnected from server"
	connection_timer.stop()  # Stop the timeout timer

# Function to handle connection timeout
func _on_connection_timeout():
	# If the connection failed and no peer was connected, update the label
	if online_label.text == "Connecting to server...":
		online_label.text = "Failed - server offline"
		print("Connection attempt timed out.")

# Function to disconnect from the server
func _on_disconnect_button_pressed():
	disconnect_from_server()

# Function to handle disconnection from the server
func disconnect_from_server():
	if multiplayer_peer != null:
		# Send a message to the server that we are disconnecting
		send_disconnect_message_to_server()

		# Disconnect the peer from the server (pass the local peer ID and a reason)
		multiplayer_peer.disconnect_peer((multiplayer.get_unique_id()), true)  # true to notify other peers
		print("Disconnected from server")
		online_label.text = "Disconnected from server"
	else:
		print("No active connection to disconnect.")
		online_label.text = "No active connection"

# Function to send a disconnection message to the server
func send_disconnect_message_to_server():
	if multiplayer_peer != null:
		# Send a custom message to the server (you can define your own message format)
		var message = "Client disconnecting"
		multiplayer_peer.send_unreliable(1, message.to_utf8())  # Channel 1, unreliable message
		print("Sent disconnect message to server")
