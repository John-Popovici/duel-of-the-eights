extends Node3D

@export var server_ip: String = ""  # EC2 public IP
@export var server_port: int = 9999

var multiplayer_peer: ENetMultiplayerPeer
var online_label: Label  
var connection_timer: Timer  
var progress_bar: ProgressBar  

func _ready():
	# Connect the button's "pressed" signal to the connect function using Callable
	var button = $VBoxContainer/ServerConnectButton  
	button.connect("pressed", Callable(self, "_on_button_pressed")) 
	
	online_label = $VBoxContainer/ServerOnlineCheck  
	if online_label == null:
		print("Error: Could not find the label for connection status.")
		return

	# Initially set the status to "Offline"
	online_label.text = "Offline"

	var disconnect_button = $VBoxContainer/ServerDisconnectButton  
	disconnect_button.connect("pressed", Callable(self, "_on_disconnect_button_pressed")) 

	# Create and configure the connection timeout timer
	connection_timer = Timer.new()
	connection_timer.wait_time = 5  
	connection_timer.one_shot = true  
	connection_timer.connect("timeout", Callable(self, "_on_connection_timeout"))
	add_child(connection_timer)  

	# Initialize the progress bar
	progress_bar = $VBoxContainer/ConnectionProgressBar  # Path to the progress bar
	if progress_bar == null:
		print("Error: Could not find the progress bar.")
		return
	progress_bar.visible = false
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0
	
	var return_button = $VBoxContainer/ReturnToIntroButton  # Add the return button
	return_button.connect("pressed", Callable(self, "_on_return_to_intro_pressed"))

# Function to handle connection to the server
func _on_button_pressed():
	connect_to_server()

# Function to create the client and connect to the server
func connect_to_server():
	# Show and reset the progress bar
	progress_bar.visible = true
	progress_bar.value = 0

	# Animate the progress bar
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 100, connection_timer.wait_time)

	multiplayer_peer = ENetMultiplayerPeer.new()
	
	# Attempt to create the client connection
	var result = multiplayer_peer.create_client(server_ip, server_port)
	if result != OK:
		print("Failed to create client connection. Error code: %d" % result)
		online_label.text = "Failed - server offline"
		progress_bar.value = 100  
		progress_bar.get("theme_override_styles/fill").bg_color = Color(1, 0, 0)
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
	progress_bar.value = 100  
	progress_bar.get("theme_override_styles/fill").bg_color = Color(0, 1, 0)  
	connection_timer.stop()  # Stop the timeout timer

# Signal handler when a peer is disconnected
func _on_peer_disconnected(id: int):
	print("Peer disconnected with ID: ", id)
	online_label.text = "Disconnected from server"
	progress_bar.value = 100
	progress_bar.get("theme_override_styles/fill").bg_color = Color(1, 0, 0)  # Red for disconnection
	connection_timer.stop()  # Stop the timeout timer

# Function to handle connection timeout
func _on_connection_timeout():
	# If the connection failed and no peer was connected, update the label
	if online_label.text == "Connecting to server...":
		online_label.text = "Failed - server offline"
		progress_bar.value = 100  
		progress_bar.get("theme_override_styles/fill").bg_color = Color(1, 0, 0)  # Red for timeout
		print("Connection attempt timed out.")

# Function to disconnect from the server
func _on_disconnect_button_pressed():
	disconnect_from_server()

# Function to handle disconnection from the server
func disconnect_from_server():
	if multiplayer_peer != null:
		# Disconnect the peer from the server
		multiplayer_peer.disconnect_peer((multiplayer.get_unique_id()), true)
		print("Disconnected from server")
		online_label.text = "Disconnected from server"
		progress_bar.value = 100 
		progress_bar.get("theme_override_styles/fill").bg_color = Color(1, 0, 0)
	else:
		print("No active connection to disconnect.")
		online_label.text = "No active connection"

# Function to handle return to main menu
func _on_return_to_intro_pressed():
	var intro_scene = load("res://Scenes/IntroScene.tscn").instantiate()
	
	# Change scene to intro scene
	get_tree().root.add_child(intro_scene)
	queue_free()
