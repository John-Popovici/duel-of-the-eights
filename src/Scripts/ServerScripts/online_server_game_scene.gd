extends Node3D

@onready var host: Button = $VBoxContainer/Host
@onready var join: Button = $VBoxContainer/Join
@onready var username: LineEdit = $VBoxContainer/Username
@onready var send: Button = $VBoxContainer/Send
@onready var message: LineEdit = $VBoxContainer/Message
@onready var messages: TextEdit = $VBoxContainer/Messages

var usrnm: String
const SERVER_IP = "54.174.171.0"
const PORT = 9999
var peer: ENetMultiplayerPeer

func _ready():
	host.pressed.connect(_on_host_pressed)
	join.pressed.connect(_on_join_pressed)
	send.pressed.connect(_on_send_pressed)

# 🟢 Host a Lobby (Also Connects as a Client)
func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var multiplayer_api = SceneMultiplayer.new()

	# 🔹 Start the server
	if peer.create_server(PORT) != OK:
		print("❌ Failed to start the server")
		return

	multiplayer_api.multiplayer_peer = peer
	get_tree().set_multiplayer(multiplayer_api)

	print("✅ Server started. Now connecting as client...")

	# 🔹 The host ALSO connects as a client
	_connect_as_client("Host_" + str(randi() % 1000))

# 🟢 Join an existing lobby
func _on_join_pressed() -> void:
	_connect_as_client("Guest_" + str(randi() % 1000))

# 🔹 Shared function to connect as client
func _connect_as_client(default_name: String) -> void:
	peer = ENetMultiplayerPeer.new()
	var multiplayer_api = SceneMultiplayer.new()

	if peer.create_client(SERVER_IP, PORT) != OK:
		print("❌ Failed to connect to server")
		return

	multiplayer_api.multiplayer_peer = peer
	get_tree().set_multiplayer(multiplayer_api)

	print("✅ Connected to server!")

	usrnm = username.text.strip_edges()
	if usrnm.is_empty():
		usrnm = default_name

	_hide_lobby_selection()

# Hide buttons & show chat UI
func _hide_lobby_selection():
	host.hide()
	join.hide()
	username.hide()
	send.show()
	message.show()

# 🟢 Send messages
func _on_send_pressed() -> void:
	if usrnm.is_empty() or message.text.is_empty():
		return

	rpc_id(1, "msg_rpc", usrnm, message.text)  # Send message to server
	message.text = ""

# 🟢 Receive messages
@rpc("any_peer", "call_local")
func msg_rpc(usrnm: String, data: String):
	messages.text += str(usrnm, ": ", data, "\n")
	messages.scroll_vertical = messages.get_line_count()
